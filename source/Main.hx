package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	//sets the starting and finish level (dependant on how many level backgrounds you create in assets/images/...)
	//game uses scalable difficulty based on level num so the game is as hard as you decide to make it
	//(i.e. enemies do 4x the damage on level 4 and spawn 4x as many of them, shield recharge scales as well for some balance)
	public static var levelNum = 1;
	public static var maxLevel = 5;
	public static var gameWin = false;

	//The global score across levels and a default highscore of zero
	public static var globalScore = 0;
    public static var highscore = 0;

	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState));
	}
}
