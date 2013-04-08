package starling.extensions.lighting.shaders
{
	import com.instagal.Shader;
	import starling.core.Starling;
	import starling.errors.AbstractMethodError;
	import starling.extensions.lighting.core.LightLayer;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	/**
	 * @author Szenia Zadvornykh
	 */
	public class StarlingShaderBase
	{
		protected var _name:String;
		protected var _programAssembler:AGALMiniAssembler;
		protected var _vertexShader:Shader;
		protected var _fragmentShader:Shader;
		protected var _vertexAgalCode:ByteArray;
		protected var _fragmentAgalCode:ByteArray;
		
		protected var _useInstagal:Boolean = false;
		
		/**
		 * abstract baseclass wrapping shader code and registration with Starling
		 */
		public function StarlingShaderBase(name:String)
		{
			_name = name;
			_programAssembler = new AGALMiniAssembler();
			//_vertexShader = new Shader( Context3DProgramType.VERTEX );
			//_fragmentShader = new Shader( Context3DProgramType.FRAGMENT );
			_vertexAgalCode = new ByteArray();
			_fragmentAgalCode = new ByteArray();
			
			register();
		}
		
		private function register():void
		{
			var target:Starling = Starling.current;
			
			if (target.hasProgram(_name))
				return;
			
			target.registerProgram(_name, assembleVertexShader(), assembleFragmentShader());
		}
		
		private function assembleVertexShader():ByteArray
		{
			if (_useInstagal)
			{
				_vertexShader = new Shader( Context3DProgramType.VERTEX );
				
				vertexShaderProgram();

				_vertexAgalCode = _vertexShader.complete();

				return _vertexAgalCode;
			}
			else {
				_programAssembler.assemble(Context3DProgramType.VERTEX, vertexShaderProgramAsString());
				
				return _programAssembler.agalcode;
			}
		}
		
		protected function vertexShaderProgramAsString():String
		{
			throw new AbstractMethodError();
		}
		
		protected function vertexShaderProgram():void
		{
			throw new AbstractMethodError();
		}
		
		private function assembleFragmentShader():ByteArray
		{
			if (_useInstagal)
			{
				_fragmentShader = new Shader( Context3DProgramType.FRAGMENT );
				
				fragmentShaderProgram();
				
				_fragmentAgalCode = _fragmentShader.complete();
				
				return _fragmentAgalCode;			
			}
			else {
				_programAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShaderProgramAsString());
			
				return _programAssembler.agalcode;
			}			
		}
		
		protected function fragmentShaderProgramAsString():String
		{
			throw new AbstractMethodError();
		}
		
		protected function fragmentShaderProgram():void
		{
			throw new AbstractMethodError();
		}
		
		final public function activate(context:Context3D):void
		{
			if (LightLayer.Program != _name)
			{
				context.setProgram(program);
				LightLayer.Program == _name
			}
			
			activateHook(context);
		}
		
		protected function activateHook(context:Context3D):void
		{
		}
		
		final public function get program():Program3D
		{
			return Starling.current.getProgram(name);
		}
		
		final public function get name():String
		{
			return _name;
		}
	}
}
