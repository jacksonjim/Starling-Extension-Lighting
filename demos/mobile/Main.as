package
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
    
    [SWF(frameRate="60", backgroundColor="#000")]
    public class Main extends Sprite
    {
        private var mStarling:Starling;
        
        public function Main()
        {
            var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
            
            Starling.multitouchEnabled = true;
            Starling.handleLostContext = !iOS;
            
            mStarling = new Starling(BasicLightingExample, stage, null, null, Context3DRenderMode.AUTO, "baseline");
            mStarling.simulateMultitouch  = false;
            mStarling.enableErrorChecking = Capabilities.isDebugger;
            
            mStarling.addEventListener(starling.events.Event.ROOT_CREATED, 
                function onRootCreated(event:Object, app:BasicLightingExample):void
                {
                    mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
                    mStarling.start();
                });
            
            NativeApplication.nativeApplication.addEventListener(
                flash.events.Event.ACTIVATE, function (e:*):void { mStarling.start(); });
            
            NativeApplication.nativeApplication.addEventListener(
                flash.events.Event.DEACTIVATE, function (e:*):void { mStarling.stop(); });
        }
    }
}