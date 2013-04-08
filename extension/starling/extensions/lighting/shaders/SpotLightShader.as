package starling.extensions.lighting.shaders
{
	import com.instagal.regs.*;	
	
	import starling.extensions.lighting.lights.SpotLight;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;

	/**
	 * @author Szenia
	 */
	public class SpotLightShader extends StarlingShaderBase
	{
		private const NAME:String = "SpotLightShader";
		
		private var params:Vector.<Number>;
		private var _vertexBuffer:VertexBuffer3D;
		private var _uvBuffer:VertexBuffer3D;
		
		public function SpotLightShader(width:int, height:int)
		{
			super(NAME);
			
			_useInstagal = true;
			
			params = new Vector.<Number>(16);
			
			params[2] = width;
			params[3] = height;
			params[4] = 0;
			params[5] = 1;
			params[11] = 1;
			params[14] = 0;
		}
		
		public function setDependencies(vertexBuffer:VertexBuffer3D, uvBuffer:VertexBuffer3D):void
		{
			_vertexBuffer = vertexBuffer;
			_uvBuffer = uvBuffer;
		}
		
		public function set light(light:SpotLight):void
		{
			params[0] = light.x;
			params[1] = light.y;
			params[6] = light.focus;
			params[7] = light.radius;
			params[8] = light.red;
			params[9] = light.green;
			params[10] = light.blue;
			params[12] = light.directionVector.x;
			params[13] = light.directionVector.y;
			params[15] = light.halfConeAngleCos();
		}
				
		override protected function activateHook(context:Context3D):void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, params);
			context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, _uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
		}
		
		override protected function vertexShaderProgram():void
		{
			_vertexShader.mov(op, a0);
			_vertexShader.mov(v0, a1);
		}
		
		override protected function vertexShaderProgramAsString():String
		{
			var program:String =
			
			"mov op, va0 \n" +
			"mov v0, va1 \n";
			
			return program;
		}
		
		override protected function fragmentShaderProgram():void
		{
			_fragmentShader.mul(t0^xy, c1^zw, v0^xy);
			_fragmentShader.sub(t0^xy, t0^xy, c1^xy);
			_fragmentShader.mov(t0^z, c2^x);
			
			_fragmentShader.nrm(t2^xyz, t1^xyz);
			_fragmentShader.dp3(t2^x, t2^xyz, c4^xyz);
			_fragmentShader.sge(t2^y, t2^x, c4^w);
			_fragmentShader.mul(t2^x, t2^x, t2^y);
			_fragmentShader.pow(t2^x, t2^x, c2^z);
			
			_fragmentShader.dp3(t1^x, t1^xyz, t1^xyz);
			_fragmentShader.sqt(t1^xyz, t1^xyz);
			_fragmentShader.div(t1^x, t1^x, c2^w);
			_fragmentShader.sat(t1^x, t1^x);
			_fragmentShader.sub(t1^x, c2^y, t1^x);
			
			_fragmentShader.mul(t2^x, t2^x, t1^x);
			_fragmentShader.mul(oc, t2^x, c3^xyz);
		}
		
		override protected function fragmentShaderProgramAsString():String
		{
			//fc1 = [light.x, light.y, width, height]
			//fc2 = [0, 1, focus, radius]
			//fc3 = [red, green, blue, 1(alpha)] = color
			//fc4 = [direction.x, direction.y, 0, cos(angle / 2)]
			
			var program:String =
			
			//get vector from fragment.xy to light.xy
			"mul ft0.xy, fc1.zw, v0.xy \n" +
			"sub ft1.xy, ft0.xy, fc1.xy \n" +
			"mov ft1.z, fc2.x \n" +
			
			//spot attenuation
			"nrm ft2.xyz, ft1.xyz \n" +
			"dp3 ft2.x, ft2.xyz, fc4.xyz \n" +
			"sge ft2.y, ft2.x, fc4.w \n" +
			"mul ft2.x, ft2.x, ft2.y \n" +
			"pow ft2.x, ft2.x, fc2.z \n" +
			
			//distance attenuation
			"dp3 ft1.x, ft1.xyz, ft1.xyz \n" +	
			"sqt ft1.xyz, ft1.xyz \n" +	
			"div ft1.x, ft1.x, fc2.w \n" +		
			"sat ft1.x, ft1.x \n" +
			"sub ft1.x, fc2.y, ft1.x \n" +
			
			//oc = distance attenuation * spotAttenuation * color
			"mul ft2.x, ft2.x, ft1.x \n" +			
			"mul oc, ft2.x, fc3.xyz";
			
			return program;
		}
	}
}
