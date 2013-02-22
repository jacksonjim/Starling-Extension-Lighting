package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DProfile;
	import starling.core.Starling;


	
	[SWF(width="800",height="480",backgroundColor="#000000",frameRate="60")]
	public class Main extends Sprite
	{
		private var starling:Starling;
		
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			starling = new Starling(BasicLightingExample, stage, null, null, Context3DRenderMode.AUTO, "baseline" /*Context3DProfile.BASELINE*/);
			starling.start();
		}
	}
}
