const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const html = fs.readFileSync('app/Resources/Web/index.html', 'utf8');
const source = html.slice(html.indexOf('function fitGame()'), html.indexOf('function enableDrag('));
const game = {style:{}}, body={clientWidth:0,clientHeight:0}, insets={paddingLeft:'0',paddingRight:'0',paddingTop:'0',paddingBottom:'0'};
const ctx={document:{body,querySelector(){return game}},getComputedStyle(){return insets},Math};
vm.runInNewContext(source,ctx);
function check(w,h,left,right,top,bottom) {
 body.clientWidth=w;body.clientHeight=h;Object.assign(insets,{paddingLeft:String(left),paddingRight:String(right),paddingTop:String(top),paddingBottom:String(bottom)});ctx.fitGame();
 const x=parseFloat(game.style.width),y=parseFloat(game.style.height);
 assert.ok(Math.abs(x/y-1.4)<1e-10);assert.ok(x<=w-left-right+1e-8);assert.ok(y<=h-top-bottom+1e-8);
 assert.ok(Math.abs(x-(w-left-right))<1e-8 || Math.abs(y-(h-top-bottom))<1e-8);
}
check(678,466,45,0,0,21); // cover, landscape
check(951,669,0,0,0,21); // inner-sized landscape
check(466,678,0,0,0,21); // rotation
check(1024,768,24,24,12,12); // iPad-like
console.log('layout fit tests passed');
