package;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.FlxGame;
import openfl.display.Sprite;

//FlxState for the main menu
class PlayState extends FlxState
{
	//initialization of graphics assets
	private var menuBackground = new FlxSprite();
	private var startButton:MenuButton;

	override public function create():Void
	{
		super.create();

        this.bgColor = FlxColor.BLACK;

		//plays some music at 85% volume
		//Music: Eric Skiff - Ascending - Resistor Anthems - Available at http://EricSkiff.com/music
		//licensed under Creative Commons 4.0 BY
		FlxG.sound.playMusic("assets/music/Ascending.wav", 0.85, true);

		//loads graphics assets
			startButton = new MenuButton(50, 150,"START GAME", () -> {
				Main.levelNum = 1;
			FlxG.switchState(new Cutscene());
		});

		menuBackground.loadGraphic("assets/images/gamebackground.png", false, 640, 480, false);

		FlxG.mouse.visible = true;

		add(menuBackground);
		add(startButton);
		add(startButton.getText());
		add(new FlxText(8, 450, 0, "GOAL: Defend the planet from invading ships at all costs!", 14));

		if(Main.highscore > 0){
			var highscoretxt = new FlxText(5, 5, 0, "HIGH SCORE", 24);
			var highscore = new Score(Main.highscore);

			highscoretxt.setPosition(465, 280);
			highscore.setPosition(480, 310);

			add(highscoretxt);
			add(highscore);
		}

		menuBackground.screenCenter();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if(startButton.pixelsOverlapPoint(FlxG.mouse.getScreenPosition(), 0) && FlxG.mouse.justPressed){
			Main.levelNum = 1;
			FlxG.switchState(new Cutscene());
		}
	}
}
