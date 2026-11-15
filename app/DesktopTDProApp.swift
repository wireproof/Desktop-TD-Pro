import SwiftUI
import WebKit
import Network

@main struct DesktopTDProApp: App {
    var body: some Scene { WindowGroup { RootView() } }
}
struct RootView: View {
    @State private var choosingIcon = false
    @StateObject private var game = GameController()
    @State private var notice: String?
    var body: some View {
        GameView(controller: game).ignoresSafeArea()
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
            .overlay(alignment: .topLeading) {
                GeometryReader { geometry in
                    Button { choosingIcon = true } label: {
                        Image(systemName: "gearshape.fill").font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white).padding(9).background(.black.opacity(0.65), in: Circle())
                    }
                    .accessibilityLabel("Game settings")
                    .position(x: geometry.size.width * (game.isPlaying ? 0.50 : 0.77),
                              y: game.isPlaying ? 21 : geometry.size.height * 0.07)
                }
            }
            .confirmationDialog("Game settings", isPresented: $choosingIcon, titleVisibility: .visible) {
                Button("Save Sandbox checkpoint") { game.command("save") }
                Button("Load Sandbox checkpoint") { game.command("load") }
                Button("Red icon (default)") { setIcon(nil) }
                Button("Purple icon") { setIcon("PurpleIcon") }
                Button("Cancel", role: .cancel) {}
            }
            .onReceive(game.$message) { if let message = $0 { notice = message; game.message = nil } }
            .alert("Desktop TD", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) {
                Button("OK", role: .cancel) { notice = nil }
            } message: { Text(notice ?? "") }
    }
    private func setIcon(_ name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { notice = "Alternate icons are not available on this device."; return }
        guard UIApplication.shared.alternateIconName != name else { return }
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error { DispatchQueue.main.async { notice = error.localizedDescription } }
        }
    }
}
final class LocalServer {
    private let queue = DispatchQueue(label: "desktoptd.local")
    private var listener: NWListener?
    var onReady: ((URL) -> Void)?
    func start() throws {
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = .hostPort(host: "127.0.0.1", port: NWEndpoint.Port(rawValue: 58882)!)
        let listener = try NWListener(using: parameters)
        self.listener = listener
        listener.stateUpdateHandler = { [weak self, weak listener] state in
            guard case .ready = state, let port = listener?.port?.rawValue,
                  let url = URL(string: "http://127.0.0.1:\(port)/index.html") else { return }
            DispatchQueue.main.async { self?.onReady?(url) }
        }
        listener.newConnectionHandler = { [weak self] connection in self?.serve(connection) }
        listener.start(queue: queue)
    }
    private func serve(_ connection: NWConnection) {
        connection.start(queue: queue)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { data, _, _, _ in
            let line = data.flatMap { String(data: $0, encoding: .utf8) }?.components(separatedBy: "\r\n").first ?? ""
            let parts = line.split(separator: " ")
            let file = parts.count > 1 ? String(parts[1].split(separator: "?").first ?? "") : ""
            let name = String(file.drop(while: { $0 == "/" }))
            let allowed = !name.isEmpty && !name.contains("/") && !name.contains("..")
            let base = Bundle.main.resourceURL?.appendingPathComponent("Web", isDirectory: true)
            let url = allowed ? base?.appendingPathComponent(name) : nil
            let payload = url.flatMap { try? Data(contentsOf: $0) }
            let type: String
            switch url?.pathExtension { case "html": type = "text/html; charset=utf-8"; case "js": type = "text/javascript"; case "wasm": type = "application/wasm"; case "swf": type = "application/x-shockwave-flash"; default: type = "application/octet-stream" }
            let body = payload ?? Data("Not found".utf8)
            let header = "HTTP/1.1 \(payload == nil ? "404 Not Found" : "200 OK")\r\nContent-Type: \(type)\r\nContent-Length: \(body.count)\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n"
            var response = Data(header.utf8); response.append(body)
            connection.send(content: response, completion: .contentProcessed { _ in connection.cancel() })
        }
    }
}
final class GameController: ObservableObject {
    weak var webView: WKWebView?
    @Published var message: String?
    @Published var isPlaying = false
    func command(_ command: String) {
        guard let webView = webView else { message = "The game is still loading."; return }
        webView.evaluateJavaScript("window.wireCheckpointCommand ? window.wireCheckpointCommand('\(command)') : 'The game is still loading.'") { [weak self] result, error in
            DispatchQueue.main.async { self?.message = error?.localizedDescription ?? (result as? String ?? "The game could not perform that action.") }
        }
    }
}
struct GameView: UIViewRepresentable {
    let controller: GameController
    func makeCoordinator() -> Coordinator { Coordinator(controller: controller) }
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration(); config.mediaTypesRequiringUserActionForPlayback = []
        config.userContentController.add(context.coordinator, name: "gameStatus")
        let web = WKWebView(frame: .zero, configuration: config); web.isOpaque = false; web.backgroundColor = .black
        web.scrollView.isScrollEnabled = false; web.navigationDelegate = context.coordinator
        controller.webView = web
        context.coordinator.server.onReady = { [weak web] url in web?.load(URLRequest(url: url)) }
        do { try context.coordinator.server.start() } catch { web.loadHTMLString("<h2>Unable to start local game server</h2>", baseURL: nil) }
        return web
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        weak var controller: GameController?
        init(controller: GameController) { self.controller = controller }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            NSLog("DesktopTD status: %@", String(describing: message.body))
            if let body = message.body as? [String: String] {
                if let status = body["checkpoint"] { controller?.message = status }
                if let screen = body["screen"] { controller?.isPlaying = (screen == "game") }
            }
        }
        let server = LocalServer()
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let u = action.request.url; decisionHandler(u?.host == "127.0.0.1" || u?.scheme == "about" ? .allow : .cancel)
        }
    }
}
