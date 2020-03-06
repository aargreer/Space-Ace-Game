package ;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.effects.FlxFlicker;
import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxColor;

//FlxSprite for enemies; contains methods for enemy being hit and one for the enemy shooting the player
class Enemy extends FlxSprite{
    public var target:FlxSprite;
    public var originalY:Float;
    private var speed:Float;

    public function new() {
        super();
        this.health = 50 + (30 * Main.levelNum);
        this.loadGraphic(FlxGraphic.fromFrames(FlxAtlasFrames.fromTexturePackerJson("assets/images/enemy-animation.png", Assets.getText("assets/images/enemy-animation.json"))), true, 75, 75, true);
        this.animation.add("fire", [1,0], 5, false, false, false);
        this.target = new FlxSprite(-150, -150, "assets/images/target-square.png");
        this.speed = Math.random() * 2.5 + 0.5;
    }

    public function getSpeed():Float{ return this.speed; }

    public function hit(amount:Float):Void{
        this.hurt(amount);

        //flicker effects for when an enemy takes damage
        if(this.alive || this.health > 0){
            FlxFlicker.flicker(this, 0.2, 0.05, true, false);
        } else { FlxFlicker.flicker(this, 0.15, 0.025, true, false, (this) -> {
            this.kill();
            this.target.kill();
        }); }
    }

    //handles tween for enemy shooting lasers
    public function fireLaser(shipPos:FlxPoint, currentPos:FlxPoint):FlxSprite{
        var beams = new FlxSprite();
        beams.loadGraphic("assets/images/enemy-laser-beam.png", false, 640, 192, false);

        beams.x = shipPos.x + 75;
        beams.y = 240;
        beams.setSize(640, 0);

        //onComplete callback for the tween, flashes red and shakes the camera violently so the player knows they've taken damage
        var customCallback:TweenCallback = (FlxTween) -> {
            FlxG.camera.flash(FlxColor.RED, 0.25, false);
            FlxG.camera.shake(0.25, 0.25, false);
        }

        var customTween = FlxTween.tween(beams, { x: currentPos.x - 312 - (shipPos.x * 0.1625), y: currentPos.y - 110, "scale.x": 0.000375, "scale.y": 0.0003125}, 0.2, { type: FlxTweenType.BACKWARD, ease: FlxEase.quadIn, onComplete: customCallback});

        //returns the tweened sprite for chaining
        return beams;
    }
}
