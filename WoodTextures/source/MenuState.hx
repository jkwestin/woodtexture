package ;

#if flash
import flash.net.FileReference;
#end
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import openfl.Lib;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIText;
import flixel.group.FlxGroup;
import flixel.util.FlxRandom;
import flixel.util.FlxColorUtil;

class MenuState extends FlxState
{
	// Variables
	private var btnNewTexture:FlxUIButton;
	private var btnSave:FlxUIButton;
	private var txtHeight:FlxInputField;
	private var txtWidth:FlxInputField;
	private var txtNumBands:FlxInputField;
	private var txtSeed:FlxInputField;
	private var txtBaseX:FlxInputField;
	private var txtBaseY:FlxInputField;
	private var txtBlur:FlxInputField;
	private var btnResetColor:FlxUIButton;
	private var txtColors:Array<FlxColorInput>;
	
	private var dh:Int = 25;
	private var colormap:Int;
	private var colorList:Array<Int>;
	private var background:FlxSprite;
	
	override public function create():Void
	{
		// Setup variables
		var w:Int = Lib.current.stage.stageWidth;
		var h:Int = Lib.current.stage.stageHeight;
		var numBands:Int = 80;
		var seed:Int = -1;
		var baseX:Int = 50;
		var baseY:Int = 600;
		var blur:Int = 6;
		
		// Add background
		background = new FlxSprite();
		background.makeGraphic(w, h, 0x0);
		add(background);
		
		// Add controls
		var i:Int = 1;
		
		btnNewTexture = new FlxUIButton(dh, dh * i++, "Update texture", newTexture);
		add(btnNewTexture);
		btnNewTexture.resize(150, 20);
		
		btnSave = new FlxUIButton(dh, dh * i++, "Save texture", saveImage);
		add(btnSave);
		btnSave.resize(150, 20);
		
		txtHeight = new FlxInputField(dh, dh * i++, "Height", h, 2048, 1);
		add(txtHeight);
		
		txtWidth = new FlxInputField(dh, dh * i++, "Width", w, 2048, 1);
		add(txtWidth);
		
		txtNumBands = new FlxInputField(dh, dh * i++, "Number of bands", numBands, 120, 2);
		add(txtNumBands);
		
		txtSeed = new FlxInputField(dh, dh * i++, "Seed", seed, 12000000, -1);
		add(txtSeed);
		
		txtBaseX = new FlxInputField(dh, dh * i++, "Base X", baseX, 20480000, 1);
		add(txtBaseX);
		
		txtBaseY = new FlxInputField(dh, dh * i++, "Base Y", baseY, 20480000, 1);
		add(txtBaseY);
		
		txtBlur = new FlxInputField(dh, dh * i++, "Blur", blur, 128, 1);
		add(txtBlur);
		
		btnResetColor = new FlxUIButton(dh, dh * i++, "Reset colormap", resetColormap);
		add(btnResetColor);
		btnResetColor.resize(150, 20);
		
		txtColors = new Array<FlxColorInput>();
		resetColormap();
		
		newTexture();
		
		super.create();
	}

	private function newTexture():Void
	{
		var h = txtHeight.int();
		var w = txtWidth.int();
		var numBands = txtNumBands.int();
		var seed = txtSeed.int();
		var baseX = txtBaseX.int();
		var baseY = txtBaseY.int();
		var blur = txtBlur.int();
		var colorList:Array<Int> = new Array<Int>();
		
		for (tc in txtColors)
		{
			colorList.push(tc.color());
		}
		
		background.pixels = WoodTexture.generateWood(w, h, numBands, seed, baseX, baseY, blur, colorList);
	}
	
	private function saveImage():Void 
	{
		var h = txtHeight.int();
		var w = txtWidth.int();
		var numBands = txtNumBands.int();
		var seed = FlxRandom.globalSeed;
		var baseX = txtBaseX.int();
		var baseY = txtBaseY.int();
		var blur = txtBlur.int();
		
		var filename:String = "Woodtexture_" + numBands + seed + baseX + baseY + blur + " (" + h + "," + w + ").png";
		var image:BitmapData = background.pixels;
		#if flash
		var png:ByteArray = PNGEncoder2.encode(image);
		var saveFile:FileReference = new FileReference();
		saveFile.save(png, filename);
		// TODO: Add save functionality for other targets
		#end
	}
	
	private function resetColormap():Void 
	{
		switch (colormap) 
		{
			case 1:
				colorList = [0xffd78e41, 0xffd8994a, 0xffcc7d38, 0xffb86a2c, 0xffae531c];
				colormap++;
			case 2:
				colorList = [14126657, 14195018, 13401400, 12085804, 11424540];
				colormap++;
			case 3:
				colorList = [14126657, 14195018, 15050326, 13401400];
				colormap++;
			case 4:
				colorList = [8003842,  8857351,  9645827,  11025688, 6953217, 5639681];
				colormap++;
			default:
				colorList = [13148538, 13741964, 12423272, 11369043, 10250049, 8933936];
				colormap = 1;
		}
		
		for (tc in txtColors) 
		{
			remove(tc);
			tc.destroy();
		}
		txtColors.splice(0, txtColors.length);
		
		var i:Int = Math.round(btnResetColor.y / dh) + 1;
		for (color in colorList)
		{
			var tc = new FlxColorInput(dh, dh * i++, color);
			txtColors.push(tc);
			add(tc);
			tc.color();
		}
		newTexture();
	}
	
}

class FlxInputField extends FlxGroup
{
	private var value:Float;
	private var max:Float;
	private var min:Float;
	private var label:FlxUIText;
	private var textfield:FlxInputText;
	
	public function new(x:Float, y:Float, name:String, value:Float = 0., max:Float = 100, min:Float = 0, fullwidth:Int = 150, labelwidth:Int= 50) 
	{
		super();
		label = new FlxUIText(x, y, labelwidth, name + ":");
		add(label);
		textfield = new FlxInputText(x + 50, y, fullwidth - labelwidth, Std.string(value));
		add(textfield);
		this.value = value;
		this.max = max;
		this.min = min;
	}
	
	public function float():Float
	{
		var newvalue:Float = Std.parseFloat(textfield.text);
		if (Std.is(newvalue, Float)) {
			value = (newvalue > max ? max : (newvalue < min ? min : newvalue));
			textfield.text = Std.string(value);
		}
		return value;
	}
	
	public function int():Int
	{
		return Math.round(float());
	}
}

class FlxColorInput extends FlxGroup
{
	private var value:Int;
	private var image:FlxSprite;
	private var textfield:FlxInputText;
	private var reg:EReg;
	
	public function new(x:Float, y:Float, color:Int = 0xFFFFFF, fullwidth:Int = 150) 
	{
		super();
		image = new FlxSprite(x, y);
		image.makeGraphic(20, 20, color, true);
		add(image);
		textfield = new FlxInputText(x + 25, y, fullwidth - 25, RGBtoHexString(color));
		add(textfield);
	}
	
	public function color():Int
	{
		var newvalue:Int;
		if (StringTools.startsWith(textfield.text, "#"))
			newvalue = Std.parseInt("0x" + textfield.text.substring(1));
		else
			newvalue = Std.parseInt(textfield.text);
		if (Std.is(newvalue, Int)) {
			value = (newvalue > 0xFFFFFF ? 0xFFFFFF: (newvalue < 0x000000 ? 0x000000 : newvalue));
			textfield.text = RGBtoHexString(value);
		}
		image.makeGraphic(20, 20, 0xFF000000 + value);
		image.draw();
		return value;
	}
	
	public override function destroy():Void {
		image.destroy();
		textfield.destroy();
		super.destroy();
	}
	
	private static inline function RGBtoHexString(Color:Int):String
	{
		var argb:ARGB = FlxColorUtil.getARGB(Color);
		return "0x" + FlxColorUtil.colorToHexString(argb.red) + FlxColorUtil.colorToHexString(argb.green) + FlxColorUtil.colorToHexString(argb.blue);
	}
}