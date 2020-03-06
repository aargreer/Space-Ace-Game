package;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.net.URLRequest;
import openfl.media.Sound;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxGame;
import openfl.display.Sprite;
import flixel.input.mouse.FlxMouse;

class Level extends FlxState {
    //initializes all the game assets and variables
    private var lasers = new FlxSprite(0, 240);
    private var background = new FlxSprite();
    private var player = new Player();
    private var ship = new FlxSprite();
    private var reticle = new FlxSprite();

    //sound elements
    private var laserSound:Sound;
    private var enemyDeathSound:Sound;
    private var enemyLaserSound:Sound;
    private var hitSound:Sound;
    private var deathSound:Sound;

    //FlxTypedGroups for the enemies and yellow target squares (done separately so the square are overlayed on top of cockpit)
    private var targets = new FlxTypedSpriteGroup<FlxSprite>(400, 400, 7 * Main.levelNum);
    private var swarm = new FlxTypedSpriteGroup<Enemy>(400, 400, 7 * Main.levelNum);
    private var score = new Score(Main.globalScore);

    //TODO: enemy movement; music; resolution; xinput; level win screen;

    override public function create():Void
    {
        //super constructor for FlxState
        super.create();

        //loop that initializes "swarm" of enemies
        //number of enemies is dependant on the level number
        for(i in 1...swarm.maxSize){
            var swarmMember = new Enemy();
            swarm.add(swarmMember);
        }

        //generates random screen positions for each enemy and adds the yellow targeting square
        swarm.forEach((it) -> {
            it.setPosition((Math.random() * 1240) + 20, (Math.random() * 275) + 50);
            it.target.setPosition(it.x - 390, it.y - 390);
            it.originalY = it.y;
            targets.add(it.target);
        }, false);

        this.bgColor = FlxColor.BLACK;

        //loads graphic assets like background, ship cockpit, aiming reticle, and laser cannons
        lasers.loadGraphic(FlxGraphic.fromFrames(FlxAtlasFrames.fromTexturePackerJson("assets/images/lasers-animation.png", Assets.getText("assets/images/lasers-animation.json"))), true, 640, 320, true);
        ship = player.getGraphic();
        background.loadGraphic("assets/images/level" + Main.levelNum + ".png", false, 1280, 480, false);
        reticle.loadGraphic("assets/images/reticle.png", false, 50, 50, false);

        //graphics size adjustments
        lasers.setGraphicSize(672, 0);
        ship.setGraphicSize(704, 0);
        reticle.setGraphicSize(1600, 0);

        //initalizing sound assets
        laserSound = new Sound(new URLRequest("assets/sounds/laser.wav"));
        enemyLaserSound = new Sound(new URLRequest("assets/sounds/enemy-laser.wav"));
        hitSound = new Sound(new URLRequest("assets/sounds/hit.wav"));
        enemyDeathSound = new Sound(new URLRequest("assets/sounds/enemy-kill.wav"));
        deathSound = new Sound(new URLRequest("assets/sounds/death-sound.wav"));

        //laser firing animation
        lasers.animation.add("fire", [1,0], 10, false, false, false);

        //adds all assets to this level state
        add(background);
        add(swarm);
        add(lasers);
        add(reticle);
        add(ship);
        add(targets);
        add(score);
        add(player.healthAmount);
        add(player.shieldAmount);

        //centers certain graphics
        lasers.screenCenter();
        ship.screenCenter();
        reticle.screenCenter();

        //have the camera follow the ship and hide the mouse cursor
        FlxG.camera.follow(ship, FlxCameraFollowStyle.NO_DEAD_ZONE);
        FlxG.mouse.visible = false;
    }

    //game loop
    override public function update(elapsed:Float):Void
    {
        //game loop constructor
        super.update(elapsed);

        //stores some useful methods as variables so they're not constantly being called each frame (mouse position, random numbers, etc.)
        var enemy = swarm.getRandom();
        var m = FlxG.mouse.getScreenPosition();
        var clicked = FlxG.mouse.justPressed;
        var mutator = Math.random();

        //if the random enemy picked to fire is dead, get the first living enemy
        if(!enemy.alive) { enemy = swarm.getFirstAlive(); }

        //shake effect with a random magniude, gives a cool "turbulence" effect
        FlxG.camera.shake(0.003 * mutator, 0.5 , false);

        //position setting based on mouse and ship position of key graphics assets
        lasers.x = (m.x * 0.05 - 15) + ship.x;
        lasers.y = m.y * 0.1 + 216;
        reticle.x = m.x - 672 + ship.x;
        reticle.y = m.y - 504;

        //adjusts the score graphic in the top left according to ship and mouse position
        if(ship.x < 640 && ship.x > 0){
            score.x = (m.x * 0.025) + ship.x;
        } else score.x = ship.x + 8;

        //if mouse pos is left of the screen, the ship moves to the left
        if(m.x <= 319) {
            ship.x -= ((320 - m.x) / 320) * 7.5;
        }

        //same as above except for mving to the right
        if(m.x >= 321) {
            ship.x += ((m.x - 320) / 320) * 7.5;
        }

        //if the ship is about to go off screen, it sets it to the right-most position
        if(ship.x > 640){
            ship.x = 640;
            score.x = 648;
        }

        //same as above except for the left screen border
        if(ship.x < 0){
            ship.x = 0;
            score.x = 8;
        }

        //returns to main menu if escape is pressed
        if(FlxG.keys.pressed.ESCAPE){
            FlxG.mouse.visible = true;
            FlxG.switchState(new PlayState());
        }

        //moves each enemy according to their speed;
        //uses the trigonometric sine of it's x coordinate to create an up and down motion;
        //less expensive than having 15-30+ tweens at once per level on top of the laser beams
        swarm.forEachAlive((it) -> {
            it.x += it.getSpeed() * mutator;
            it.target.x += it.getSpeed() * mutator;

            it.y = it.originalY + (50 * Math.sin(it.x / (1280 / (20 * Math.PI))));
            it.target.y = it.y + 8;

            if(it.x > 1280){
                it.x = 0;
                it.target.x = 8;
            }
        }, false);

        //if the player has clicked this frame, performs all the logic for the laser tween and hit methods
        if(clicked){
            //laser sound and animation
            laserSound.play(0, 0);
            lasers.animation.play("fire");

            //preprocessor conditional; if the machine is multithreaded, it creates a laser tween and kills it in a separate thread (the only thread-safe way to do this in my testing)
            #if (target.threaded)
                var beams = playerLaserBeam(new FlxPoint(reticle.x + 672, reticle.y + 714), new FlxPoint(lasers.x, lasers.y - 50), new FlxPoint(ship.x, ship.y));

                sys.thread.Thread.create(() -> {
                    Sys.sleep(0.125);
                    beams.kill();
                });
            #end


            //if the mouse is over the hitbox of any enemy, adds score and hits the enemy
            swarm.forEachAlive((it) -> {
                if(it.pixelsOverlapPoint(new FlxPoint(reticle.x + 672, reticle.y + 504), 0)){
                    if(!it.alive){
                        it.kill();
                    } else {
                        it.hit(20);
                        score.add(10);

                        if(it.health <= 0){
                            score.add(100 + (25 * Main.levelNum));
                            enemyDeathSound.play(0, 0);
                            it.target.kill();
                            it.kill();
                        }
                    }
                }
            }, false);
        }

        //random chance that a living enemy wil fire at the player (1.75% chance per living, on screen enemy per frame)
        if(mutator > 0.9825 && enemy.alive && enemy.isOnScreen()){

            //enemy firing animation, same logic as before except it plays the tween in reverse (with green lasers)
            //enemy damage is a function of level number
            enemy.animation.play("fire");
            enemyLaserSound.play(0, 0);
            player.hit(10 * Main.levelNum);

            #if (target.threaded)
                var beams = enemy.fireLaser(new FlxPoint(ship.x, ship.y), enemy.getGraphicMidpoint());
                add(beams);

                sys.thread.Thread.create(() -> {
                    Sys.sleep(0.25);
                    hitSound.play(0, 0);
                    beams.kill();
                });
            #end
        }

        //regens a percentage of shields based on level number (i.e. on level 2, 0.666667% * 60 frames per second = 4% per second)
        player.shieldRegen(0.33332 * Main.levelNum);

        //gets health and shields for HUD display
        player.shieldAmount.text = "SHIELD:  " + Math.floor(player.getShields());
        player.healthAmount.text = "HEALTH:  " + Math.floor(player.getHP());
        player.shieldAmount.x = ship.x + 275;
        player.healthAmount.x = ship.x + 275;

        //if no living enemies, sets the current score as the highscore if its higher, then moves to next level
        if(swarm.countLiving() <= 0){
            if(score.getScore() > Main.highscore) { Main.highscore = score.getScore(); }
            Main.globalScore = score.getScore();
            Main.levelNum++;

            if(Main.levelNum <= Main.maxLevel){ FlxG.switchState(new Cutscene()); } else {
                Main.gameWin = true;
                FlxG.switchState(new GameOver());
            }
        }

        //if player is dead, get the score, set theh highscore if necessary, and plays the game over screen
        if(!player.alive || player.getHP() <= 0){
            deathSound.play(0, 0);
            if(score.getScore() > Main.highscore) { Main.highscore = score.getScore(); }
            FlxG.mouse.visible = false;
            Main.globalScore = score.getScore();
            FlxG.switchState(new GameOver());
        }
    }

    //function for generating laser tween
    private function playerLaserBeam(m:FlxPoint, laserPos:FlxPoint, shipPos:FlxPoint):FlxSprite{
        var beams = new FlxSprite();
        beams.loadGraphic("assets/images/laser-beam.png", false, 640, 192, false);

        //variables for a pseudo-parallax effect; makes the laser go towards where the mouse is pointed
        var mouseVertAdjust = (1 - ((480 - m.y) / 480));
        var invMouseVertAdjust = (480 - m.y) / 480;

        //sets size and start point of tween
        beams.x = laserPos.x;
        beams.y = laserPos.y + (mouseVertAdjust * 25) + 75;
        beams.setSize(300, (invMouseVertAdjust * 144));

        //generates tween
        var customTween = FlxTween.tween(beams, { x: m.x - beams.x - 320 + shipPos.x, y: m.y - beams.y + 15 - (invMouseVertAdjust * 105), "scale.x": 0.0075, "scale.y": 0.00625}, 0.175, { type: FlxTweenType.ONESHOT, ease: FlxEase.expoOut });
        add(beams);

        //returns the sprite for chaining purposes
        return beams;
    }
}