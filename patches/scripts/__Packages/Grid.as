class Grid extends MovieClip
{
   var active;
   var cCell;
   var cCol;
   var cRow;
   var cols;
   var dragTower;
   var game;
   var gotoAlpha;
   var gridRatio;
   var gridSize;
   var hCell;
   var hRange;
   var hTower;
   var pathMC;
   var rows;
   var showCell;
   var startX;
   var startY;
   var tower;
   function Grid()
   {
      super();
      this.gotoAlpha = 0;
      this._alpha = 0;
      this.active = false;
      this.hCell = _root.attachMovie("hCell","hCell",21);
      this.hCell._visible = false;
      this.hCell._alpha = 50;
      this.showCell = false;
      this.hRange = _root.attachMovie("hRange","hRange",20);
      this.hRange._visible = false;
      this.hRange._alpha = 30;
      this.hRange.stop();
      this.hTower = _root.attachMovie("hTower","hTower",30);
      this.hTower._alpha = 65;
      this.hTower._visible = false;
      this.hCell.goldChar._visible = false;
   }
   function Destroy()
   {
      if(_root.hTower)
      {
         _root.hTower.removeMovieClip();
      }
      if(_root.hRange)
      {
         _root.hRange.removeMovieClip();
      }
      if(_root.hCell)
      {
         _root.hCell.removeMovieClip();
      }
      if(this.pathMC)
      {
         this.pathMC.removeMovieClip();
      }
      this.game = undefined;
      this.rows = undefined;
      this.cols = undefined;
      this.startX = undefined;
      this.startY = undefined;
      this.gridSize = undefined;
      this.gridRatio = undefined;
   }
   function Init()
   {
      this.game = Game.me;
      this.rows = this.game.gameInfo.cellRows;
      this.cols = this.game.gameInfo.cellCols;
      this.startX = this.game.gameInfo.startX;
      this.startY = this.game.gameInfo.startY;
      this.gridSize = this.game.gameInfo.gridSize;
      this.gridRatio = this.game.gameInfo.gridRatio;
   }
   function onEnterFrame()
   {
      if(this.active)
      {
         if(this.gotoAlpha > this._alpha)
         {
            this._alpha += 10;
            if(this.gotoAlpha < this._alpha)
            {
               this.active = false;
            }
         }
         else
         {
            this._alpha -= 10;
            if(this.gotoAlpha > this._alpha)
            {
               this.active = false;
            }
         }
      }
      if(this.dragTower)
      {
         this.HighlightCell();
      }
   }
   function SelectTower(t)
   {
      this.tower = t;
      this.SetRange(t);
      this.hRange._visible = true;
   }
   function SetRange(t)
   {
      this.hTower._width = this.hTower._height = this.gridSize * 2;
      if(t.rangeType == 1)
      {
         this.hRange._xscale = this.hRange._yscale = int(t.range2 * 2 / 64 * 100);
         if(t.minRange2 > 0)
         {
            this.hRange.gotoAndStop(2);
         }
         else if(t.towerType == 9)
         {
            this.hRange.gotoAndStop(3);
         }
         else
         {
            this.hRange.gotoAndStop(1);
         }
      }
      else if(t.rangeType == 2)
      {
         this.hRange._xscale = this.hRange._yscale = int(100 * this.gridSize / 14);
         this.hRange.gotoAndStop(4);
      }
      this.hRange._x = t.topLeftCell.left + this.gridSize;
      this.hRange._y = t.topLeftCell.top + this.gridSize;
   }
   function CancelSelect()
   {
      if(this.tower)
      {
         this.hRange._visible = false;
         this.tower.CancelSelect();
         this.tower = undefined;
      }
   }
   function ToggleGrid()
   {
      if(!GameGUI.gridOn)
      {
         this.gotoAlpha = 0;
      }
      if(GameGUI.gridOn)
      {
         this.gotoAlpha = 50;
      }
      this.active = true;
   }
   function FollowTower(t)
   {
      if(!GameGUI.gridOn)
      {
         this.gotoAlpha = 50;
         this.active = true;
      }
      this.showCell = true;
      this.dragTower = t;
      this.hCell._width = this.gridSize * t.size - 2;
      this.hCell._height = this.hCell._width;
      this.SetRange(t);
      this.HighlightCell();
   }
   function StopFollowTower()
   {
      if(!GameGUI.gridOn)
      {
         this.gotoAlpha = 0;
         this.active = true;
      }
      this.showCell = false;
      this.hCell._visible = false;
      this.hRange._visible = false;
      this.cRow = -1;
      this.cCol = -1;
      this.hitTest = 4;
      this.dragTower.dragged = false;
      this.dragTower = undefined;
   }
   function onMouseDown()
   {
      var _loc6_;
      var _loc5_;
      var _loc4_;
      var _loc3_;
      if(this.dragTower)
      {
         this.HighlightCell();
         if(this.hitTest == 0)
         {
            this.game.DropTower(this.dragTower,this.cCell);
         }
         else if(!this.game.shiftDown)
         {
            this.game.CancelSelect();
         }
      }
      else if(this.tower)
      {
         _loc6_ = _root._xmouse;
         _loc5_ = _root._ymouse;
         _loc4_ = int((_loc6_ - this.startX) / this.gridSize);
         _loc3_ = int((_loc5_ - this.startY) / this.gridSize);
         if(_loc4_ >= 0 && _loc4_ < this.cols && _loc3_ >= 0 && _loc3_ < this.rows && this.hitTest != 3 && !this.game.shiftDown)
         {
            _root.tt.UserAction("towerdeselect");
            this.game.CancelSelect();
         }
      }
   }
   function HighlightCell()
   {
      var _loc7_;
      var _loc6_ = _root._xmouse;
      var _loc5_ = _root._ymouse;
      var _loc4_ = int((_loc6_ - this.startX) / this.gridSize);
      var _loc3_ = int((_loc5_ - this.startY) / this.gridSize);
      if(_loc4_ < 0 || _loc4_ >= this.cols || _loc3_ < 0 || _loc3_ >= this.rows)
      {
         this.hCell._visible = false;
         this.hRange._visible = false;
         this.cRow = -1;
         this.cCol = -1;
         this.cCell = undefined;
         this.hitTest = 4;
      }
      else
      {
         _loc7_ = this.game.gameInfo.cells[_loc3_][_loc4_];
         if(_loc5_ < _loc7_.top + this.gridSize / 2)
         {
            this.cRow = _loc3_ - 1;
         }
         else
         {
            this.cRow = _loc3_;
         }
         if(_loc6_ < _loc7_.left + this.gridSize / 2)
         {
            this.cCol = _loc4_ - 1;
         }
         else
         {
            this.cCol = _loc4_;
         }
         if(this.cCol < 0)
         {
            this.cCol = 0;
         }
         if(this.cRow < 0)
         {
            this.cRow = 0;
         }
         if(this.cCol >= this.cols - 1)
         {
            this.cCol = this.cols - 2;
         }
         if(this.cRow >= this.rows - 1)
         {
            this.cRow = this.rows - 2;
         }
         this.cCell = this.game.gameInfo.cells[this.cRow][this.cCol];
         if(this.showCell)
         {
            this.hCell._x = this.cCell.left;
            this.hCell._y = this.cCell.top;
            this.hCell._visible = true;
         }
         this.hRange._x = this.cCell.left + this.gridSize;
         this.hRange._y = this.cCell.top + this.gridSize;
         this.hRange._visible = true;
         this.hitTest = this.CellHitTest(this.cRow,this.cCol,this.dragTower);
      }
      if(this.hitTest == 0)
      {
         this.hCell.gotoAndStop(1);
      }
      else
      {
         this.hCell.gotoAndStop(2);
      }
   }
   function CellHitTest(cellRow, cellCol, t)
   {
      var _loc3_;
      var _loc4_ = 0;
      if(ModeSettings.maxTowers > 0 && this.game.gameInfo.towers.length >= ModeSettings.maxTowers)
      {
         return 2;
      }
      var _loc7_;
      var _loc5_;
      var _loc2_;
      if(this.game.gold.Get() >= t.cost.Get())
      {
         _loc7_ = this.game.gameInfo.cells;
         _loc5_ = 0;
         while(_loc5_ < t.size)
         {
            _loc2_ = 0;
            while(_loc2_ < t.size)
            {
               _loc3_ = _loc7_[cellRow + _loc5_][cellCol + _loc2_];
               if(_loc3_.cost == 0)
               {
                  _loc4_ = 2;
                  break;
               }
               if(_loc3_.creepCount > 0)
               {
                  _loc4_ = 3;
                  break;
               }
               if(_loc3_.barrier)
               {
                  _loc4_ = 4;
                  break;
               }
               _loc2_ = _loc2_ + 1;
            }
            if(_loc4_ > 0)
            {
               break;
            }
            _loc5_ = _loc5_ + 1;
         }
      }
      else
      {
         _loc4_ = 1;
      }
      return _loc4_;
   }
   function DrawGrid()
   {
      this.clear();
      this.lineStyle(1,11184810);
      var _loc8_ = this.startY + this.rows * this.gridSize;
      var _loc9_ = this.startX + this.cols * this.gridSize;
      var _loc7_ = int(this.gridSize * 10 / this.gridRatio);
      this.lineStyle(1,16777215,80);
      this.moveTo(this.startX + this.cols / 2 * this.gridSize,this.startY + _loc7_);
      this.lineTo(this.startX + this.cols / 2 * this.gridSize,_loc8_ - _loc7_);
      this.moveTo(this.startX + _loc7_,this.startY + this.rows / 2 * this.gridSize);
      this.lineTo(_loc9_ - _loc7_,this.startY + this.rows / 2 * this.gridSize);
      this.lineStyle(1,16777215,0);
      var _loc6_ = 0;
      var _loc4_;
      var _loc2_;
      var _loc3_;
      var _loc5_;
      while(_loc6_ < this.rows)
      {
         _loc4_ = 0;
         while(_loc4_ < this.cols)
         {
            _loc2_ = this.game.gameInfo.cells[_loc6_][_loc4_];
            _loc3_ = false;
            if(_loc2_.barrier && _loc2_.cost == 0)
            {
               _loc3_ = true;
               _loc5_ = 16777215;
            }
            else if(_loc2_.isExit)
            {
               _loc3_ = true;
               _loc5_ = 0;
            }
            if(_loc3_)
            {
               this.beginFill(_loc5_,80);
               this.moveTo(_loc2_.left,_loc2_.top);
               this.lineTo(_loc2_.left + this.gridSize,_loc2_.top);
               this.lineTo(_loc2_.left + this.gridSize,_loc2_.top + this.gridSize);
               this.lineTo(_loc2_.left,_loc2_.top + this.gridSize);
               this.lineTo(_loc2_.left,_loc2_.top);
               this.endFill();
            }
            _loc4_ = _loc4_ + 1;
         }
         _loc6_ = _loc6_ + 1;
      }
      this.cacheAsBitmap = true;
   }
   function DrawMoveCosts()
   {
      return undefined;
   }
   function DrawRanges()
   {
      var _loc3_;
      var _loc6_ = new TextFormat();
      _loc6_.bold = false;
      _loc6_.font = "_sans";
      _loc6_.color = 0;
      _loc6_.size = 7;
      this.pathMC = this.createEmptyMovieClip("pathmc",0);
      var _loc5_ = 0;
      var _loc4_;
      var _loc2_;
      while(_loc5_ < this.rows)
      {
         _loc4_ = 0;
         while(_loc4_ < this.cols)
         {
            _loc2_ = this.game.gameInfo.cells[_loc5_][_loc4_];
            if(_loc2_.rangeTowers.length > 0)
            {
               this.pathMC.beginFill(16715792,80);
               this.pathMC.moveTo(_loc2_.left,_loc2_.top);
               this.pathMC.lineTo(_loc2_.left + this.gridSize,_loc2_.top);
               this.pathMC.lineTo(_loc2_.left + this.gridSize,_loc2_.top + this.gridSize);
               this.pathMC.lineTo(_loc2_.left,_loc2_.top + this.gridSize);
               this.pathMC.lineTo(_loc2_.left,_loc2_.top);
               this.pathMC.endFill();
               _loc3_ = this["tf:" + _loc5_ + ":" + _loc4_];
               if(_loc3_)
               {
                  _loc3_.text = "" + _loc2_.rangeTowers.length;
               }
               else
               {
                  _loc3_ = this.pathMC.createTextField("tf:" + _loc5_ + ":" + _loc4_,this.pathMC.getNextHighestDepth(),_loc2_.left,_loc2_.top,this.gridSize,this.gridSize);
                  _loc3_.setTextFormat(_loc6_);
                  _loc3_.text = String(_loc2_.rangeTowers.length);
                  _loc3_.selectable = false;
               }
            }
            else
            {
               _loc3_ = this["tf:" + _loc5_ + ":" + _loc4_];
               if(_loc3_)
               {
                  _loc3_.removeTextField();
               }
            }
            _loc4_ = _loc4_ + 1;
         }
         _loc5_ = _loc5_ + 1;
      }
   }
}
