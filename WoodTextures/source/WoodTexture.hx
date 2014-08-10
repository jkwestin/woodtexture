package ;

import openfl.display.BitmapData;
import openfl.filters.BlurFilter;
import openfl.geom.Matrix;
import openfl.geom.Point;
import flixel.util.FlxRandom;

/**
 * ...
 * @author JKW
 */
class WoodTexture
{	
	
	public static function generateWood(displayWidth:Int, displayHeight:Int, numBands:Int = 80, seed:Int = -1, perlinBaseX:Int = 50, perlinBaseY:Int = 600, blurSize:Int = 6, colorList:Array<Int>):BitmapData
	{
		// Initiate FlxRandom
		if (seed < 0)
			seed = FlxRandom.resetGlobalSeed();
		else
			FlxRandom.globalSeed = seed;
		if (colorList.length == 0)
			colorList = [0xffd78e41, 0xffd8994a, 0xffcc7d38, 0xffb86a2c, 0xffae531c];
		
		var scale:Int = 2;
		
		var perlinData:BitmapData = new BitmapData(scale * displayWidth, scale * displayHeight, false, 0x000000);
		var woodPatternData:BitmapData = new BitmapData(scale * displayWidth, scale * displayHeight, false, 0x000000);
		var displayData:BitmapData = new BitmapData(displayWidth, displayHeight, false, 0x000000);
		
		var origin:Point = new Point(0, 0);
		
		var rArray:Array<Int> = new Array<Int>();
		var gArray:Array<Int> = new Array<Int>();
		var bArray:Array<Int> = new Array<Int>();
		
		// Set color thresholds
		var r:Int;var g:Int;var b:Int;
		var index:Int;var color:Int;
		var rInitArray:Array<Int> = new Array<Int>();
		var gInitArray:Array<Int> = new Array<Int>();
		var bInitArray:Array<Int> = new Array<Int>();
		
		//Reset color choice list
		var colorChoices:Array<Int> = new Array<Int>();
		for (color in colorList) 
		{
			colorChoices.push(color);
		}
		
		//Randomly select colors from color list
		var choiceIndex:Int;
		var lastChoice:Int = colorChoices.splice(0, 1)[0];
		for (i in 0...numBands) 
		{
			choiceIndex = FlxRandom.intRanged(0, colorChoices.length - 1);
			color = colorChoices[choiceIndex];
			
			r = (color >> 16 & 0xFF) << 16;
			g = (color >> 8 & 0xFF) << 8;
			b = color & 0xFF;
			
			//trace(FlxColorUtil.ARGBtoHexString(color));
			
			rInitArray.push(r);
			gInitArray.push(g);
			bInitArray.push(b);
			
			//Remove chosen color
			colorChoices.splice(choiceIndex, 1);
			
			//Replace last choice and update lastChoice
			colorChoices.push(lastChoice);
			lastChoice = color;
		}
		
		for (i in 0...256) 
		{
			index = Math.floor(i / 255 * (numBands - 1));
			rArray.push(rInitArray[index]);
			gArray.push(gInitArray[index]);
			bArray.push(bInitArray[index]);
		}
		
		// Fill Perlin Noise
		perlinData.perlinNoise(perlinBaseX, perlinBaseY, 4, seed, false, true, 7, true);
		perlinData.applyFilter(perlinData, perlinData.rect, new Point(), new BlurFilter(blurSize, blurSize));
		
		// Make regular color bands
		woodPatternData.paletteMap(perlinData, perlinData.rect, origin, rArray, gArray, bArray);
		
		// Downsample texture
		displayData.draw(woodPatternData, new Matrix(1 / scale, 0, 0, 1 / scale));
		
		return displayData;
	}
	
}