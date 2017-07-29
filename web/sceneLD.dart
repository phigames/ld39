part of ld39;

class SceneLD extends Scene {

  Wire wire;

  SceneLD() : super(0x222222, 'scene', 200) {

  }

  void create() {
    super.create();
    wire = new Wire(this, 'wire', 100, 100, true, 25, 5, 300, 300);
    batteries.add(new Battery(this, 3, 300, 200));
    game.world.bringToTop(light);
  }

  void preload() {
    super.preload();
    game.load.image('battery_3', 'res/battery_3.png');
    game.load.image('wire', 'res/wire.png');
  }

  void render() {

  }

  void update() {
    super.update();
    wire.update();
    for (Battery battery in batteries) {
      for (var body in wire.attachableEnds) {
        if (distance(battery.sprite.x, battery.sprite.y, body.x, body.y) < 50) {
          if (!battery.plusAttached) {
            game.physics.p2.createRevoluteConstraint(battery.sprite.body, [ -battery.sprite.width / 2, 0 ], body, [ 0, 0 ]);
            battery.plusAttached = true;
          } else if (!battery.minusAttached) {
            game.physics.p2.createRevoluteConstraint(battery.sprite.body, [ battery.sprite.width / 2, 0 ], body, [ 0, 0 ]);
            battery.minusAttached = true;
          } else {
            break;
          }
          wire.attachableEnds.remove(body);
          battery.sprite.body.setCollisionGroup(wireCollisionGroup);
          break;
        }
      }
      if (mouseClicked && distance(mouseX, mouseY, battery.sprite.body.x, battery.sprite.body.y) < 50) {
        battery.hit();
        mouseClicked = false;
      }
    }
  }

}