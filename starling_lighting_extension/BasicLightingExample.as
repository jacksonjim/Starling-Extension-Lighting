package 
{
	import com.zadvorsky.displayObjects.RegularPolygon;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.extensions.lighting.core.LightLayer;
	import starling.extensions.lighting.geometry.RegularPolygonShadowGeometry;
	import starling.extensions.lighting.lights.DirectionalLight;
	import starling.extensions.lighting.lights.PointLight;
	import starling.extensions.lighting.lights.SpotLight;
	import starling.textures.Texture;
	import starling.animation.Transitions;

	import flash.display.Stage;
	import flash.events.MouseEvent;


	/**
	 * @author Szenia Zadvornykh
	 */
	public class BasicLightingExample extends Sprite
	{
		private var lightLayer:LightLayer;
		
		private var mouseLight:PointLight;
		private var lights:Vector.<PointLight>;
		
		private var geometry:Vector.<DisplayObject>;
				
		private var nativeStage:Stage;
		private var nativeStageWidth:int = 1000;
		private var nativeStageHeight:int = 1000;
		
		private var helperPoint:Point = new Point();
		
		public function BasicLightingExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		private function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			Starling.current.showStats = true;

			nativeStage = Starling.current.nativeStage;
			nativeStageWidth = nativeStage.stageWidth;
			nativeStageHeight = nativeStage.stageHeight;
			
			//create the LightLayer coverting the stage
			//this where the lights and shadows are rendered
			lightLayer = new LightLayer(nativeStageWidth, nativeStageHeight, 0x000000, 0, 1);
			
			//uncomment this to add a background image with random perlin noise to see how the lights might look on a texture 
			var bmd:BitmapData = new BitmapData(nativeStageWidth, nativeStageHeight, false, 0xffffffff);
			var seed:Number = Math.floor(Math.random()*100);
			bmd.perlinNoise(320, 240, 8, seed, true, true, 7, false, null);
			addChild(new Image(Texture.fromBitmapData(bmd)));
			
			createLights();
			createGeometry();
			
			//add the lightLayer last, so it is on top of other display objects
			addChild(lightLayer);
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			nativeStage.addEventListener(MouseEvent.CLICK, clickHandler);
		}

		private function createLights():void
		{
			//create a white light that will follow the mouse position
			mouseLight = new PointLight(0, 0, 200, 0xffffff, 1);
			//add it to the light layer
			lightLayer.addLight(mouseLight);
			
			lights = new <PointLight>[];
			
			//create a low intensity directional light, casting shadows at a 60 degree angle
			var directionalLight:DirectionalLight = new DirectionalLight(60, 0xffffff, 0.1);
			lightLayer.addLight(directionalLight);
			
			//create a few spotlights
			var spotLight:SpotLight;
			
			spotLight = new SpotLight(0, 0, 600, 45, 60, 20, 0xff0000, 3);
			lightLayer.addLight(spotLight);

			spotLight = new SpotLight(nativeStageWidth / 2, 0, 600, 90, 60, 20, 0x00ff00, 3);
			lightLayer.addLight(spotLight);

			spotLight = new SpotLight(nativeStageWidth, 0, 600, 135, 60, 20, 0x0000ff, 3);
			lightLayer.addLight(spotLight);
			
			//uncomment this to add an arbitrary number of random lights
//			var light:Light;
//			
//			for(var i:int; i < 20; i++)
//			{
//				light = new Light(Math.random() * nativeStageWidth, Math.random() * nativeStageHeight, 200 + Math.random() * 400, Math.random() * 0xffffff, 1);
//				
//				lightLayer.addLight(light);
//				lights.push(light);
//			}
		}

		private function createGeometry():void
		{
			geometry = new <DisplayObject>[];

			var polygon:RegularPolygon;
			var r:int;
			var v:int;
			
			//create an arbitrary number of quads to act as shadow geometry
			for(var i:int; i < 20; i++)
			{
				r = 10 + Math.round(Math.random() * 10);
				v = 3 + Math.round(Math.random() * 3);

				polygon = new RegularPolygon(r, v, Math.random() * 0xffffff);
				polygon.pivotX = polygon.width >> 1;
				polygon.pivotY = polygon.height >> 1;
				polygon.x = Math.random() * nativeStageWidth;
				polygon.y = Math.random() * nativeStageHeight;
				
				//this takes the bounding box of the quad to create geometry that blocks light
				//the QuadShadowGeometry class also accepts Images
				//if you want to create more complex geometry for a display object, 
				//you can make your own ShadowGeometry subclass, and override the createEdges method
				lightLayer.addShadowGeometry(new RegularPolygonShadowGeometry(polygon));
				
				//add the quad to the stage
				//the quad will cast shadows even if it is not on the display list (I might change this later)
				//to remove shadow geometry assosiated with a display object, call LightLayer.removeGeometryForDisplayObject 			
				addChild(polygon);
				
				scaleObject(polygon);
				moveObject(polygon);
				
				geometry.push(polygon);
			}
		}
		
		private function scaleObject(object:DisplayObject, up:Boolean = false):void {
			Starling.juggler.tween(object, 1 + Math.round(Math.random() * 2), {
				transition: Transitions.EASE_IN_OUT_ELASTIC,
				scaleX: up ? 1 : 0.5,
				scaleY: up ? 1 : 0.5,
				
				onComplete: function():void {
					scaleObject(object, !up);
				}
			});
		}

		private function moveObject(object:DisplayObject):void {
			var nX:Number = Math.random() * nativeStageWidth;
			var nY:Number = Math.random() * nativeStageHeight;
			
			helperPoint.setTo(x, y);
			
			var l1:Number = helperPoint.length;
			
			helperPoint.setTo(nX, nY);
			
			var l2:Number = helperPoint.length;
			
			var time:Number = 1 + Math.round(10 * Math.abs(l1 - l2) / Math.max(nativeStageWidth, nativeStageHeight));
			
			Starling.juggler.tween(object, time, {
				transition: Transitions.EASE_OUT,
				x: nX,
				y: nY,
				
				onComplete: function():void {
					moveObject(object);
				}
			});
		}

		private function clickHandler(event:MouseEvent):void
		{
			var light:PointLight;
			light = new PointLight(nativeStage.mouseX, nativeStage.mouseY, 100 + Math.random() * 500, Math.random() * 0xffffff, 1);
				
			lightLayer.addLight(light);
			lights.push(light);
		}
		
		private function update(event:EnterFrameEvent):void
		{
			mouseLight.x = nativeStage.mouseX;
			mouseLight.y = nativeStage.mouseY;
			
			/*
			var dx:int;
			var dy:int;
			var rad:Number;
			
			//rotate the quads to face the mouse position
			for each(var g:DisplayObject in geometry)
			{
				dx = g.x - mouseLight.x;
				dy = g.y - mouseLight.y;
				
				rad = -Math.atan2(dx, dy);
				g.rotation = rad;
			}
			*/
		}
	}
}
