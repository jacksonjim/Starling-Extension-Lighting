package starling.extensions.lighting.core
{
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;

	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * @author Szenia Zadvornykh
	 */
	public class ShadowGeometry
	{
		protected static var start:Point = new Point();
		protected static var end:Point = new Point();
		
		private var _modelEdges:Vector.<Edge>;
		private var _worldEdges:Vector.<Edge>;
		
		private var _displayObject:DisplayObject;
		
		private var tempTransformationMatrix:Matrix;
		
		/**
		 * abstract baseclass to hold geometry used for shadow casting
		 * do NOT use this class, instead use QuadShadowGeometry, PolygonShadowGeometry or your own implementation
		 */
		public function ShadowGeometry(displayObject:DisplayObject)
		{
			_displayObject = displayObject;
			
			tempTransformationMatrix = new Matrix();
			
			_modelEdges = createEdges();
			_worldEdges = new <Edge>[];
			
			var edge:Edge;
			var length:int = _modelEdges.length - 1;
			
			for (var i:int = length; i >= 0; i--)
			{
				_worldEdges.push(new Edge());
			}
			
			//transform();
		}
		
		/**
		 * override this method in a custom implementation to create more complex geometry
		 */
		protected function createEdges():Vector.<Edge>
		{
			return null;
		}
		
		final public function transform():void
		{
			tempTransformationMatrix.identity();
			
			RenderSupport.transformMatrixForObject(tempTransformationMatrix, _displayObject);
			
			var modelEdge:Edge;
			var worldEdge:Edge;
			var length:int = _modelEdges.length;
			
			for (var i:int = length-1; i >=0; i--)
			{
				modelEdge = _modelEdges[i];
				worldEdge = _worldEdges[i];
				
				start.setTo(modelEdge.startX, modelEdge.startY);
				transformPoint(start, tempTransformationMatrix);
				
				end.setTo(modelEdge.endX, modelEdge.endY);
				transformPoint(end, tempTransformationMatrix);

				worldEdge.startX = start.x;
				worldEdge.startY = start.y;
				worldEdge.endX = end.x;
				worldEdge.endY = end.y;
			}
		}
		
		final public function get worldEdges():Vector.<Edge>
		{
			return _worldEdges;
		}

		final public function get displayObject():DisplayObject
		{
			return _displayObject;
		}

		public function dispose():void
		{
			_displayObject = null;
			_modelEdges = null;
			_worldEdges = null;
			tempTransformationMatrix = null;
		}
		
		final private function transformPoint(point:Point, matrix:Matrix):void
		{
			if (point && matrix)
			{
				point.setTo(matrix.a * point.x + matrix.c * point.y + matrix.tx, matrix.b * point.x + matrix.d * point.y + matrix.ty);
			}
		}
	}
}
