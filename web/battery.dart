part of ld39;

class Battery {

  static const num TEAR_THRESHOLD = 700;
  static const int THREE_V = 3;
  static const int NINE_V = 9;

  Scene scene;
  phaser.Sprite<p2.Body> sprite; // store body?
  num plusX, plusY, minusX, minusY;
  int voltage;
  p2.RevoluteConstraint tearConstraintPlus, tearConstraintMinus;
  Wire tearWirePlus, tearWireMinus;
  p2.Body tearBodyPlus, tearBodyMinus;
  bool equilibriumPlus, equilibriumMinus;
  num disconnectPlusTimer, disconnectMinusTimer;

  Battery(this.scene, this.voltage, num x, num y) {
    sprite = game.add.sprite(x, y, 'battery_$voltage');
    game.physics.p2.enable(sprite);
    if (voltage == THREE_V) {
      plusX = 0;
      plusY = -40;
      minusX = 0;
      minusY = 40;
      sprite.body.clearShapes();
      sprite.body.addRectangle(40, 70, 0, 10);
    } else if (voltage == NINE_V) {
      plusX = -10;
      plusY = -40;
      minusX = 10;
      minusY = -40;
      sprite.body.clearShapes();
      sprite.body.addRectangle(50, 70, 0, 10);
    }
    sprite.body.setCollisionGroup(scene.mouseCollisionGroup);
    sprite.body.collides(scene.mouseCollisionGroup);
    //sprite.body.collides(scene.wireCollisionGroup);
    equilibriumPlus = equilibriumMinus = false;
    disconnectPlusTimer = disconnectMinusTimer = 0;
  }

  void hit(num angle) {
    sprite.body.velocity.x = cos(angle) * 1000;
    sprite.body.velocity.y = sin(angle) * 1000;
  }

  void update() {
    if (tearConstraintPlus == null || tearConstraintMinus == null) {
      for (Wire wire in scene.wires) {
        for (p2.Body body in wire.attachableEnds) {
          num pA = angle(0, 0, plusX, plusY) + sprite.body.angle / 180 * PI;
          num pD = distance(0, 0, plusX, plusY);
          num pX = sprite.body.x + cos(pA) * pD;
          num pY = sprite.body.y + sin(pA) * pD;
          if (tearConstraintPlus == null && disconnectPlusTimer == 0 && distance(pX, pY, body.x, body.y) < 30) {
            tearConstraintPlus = game.physics.p2.createRevoluteConstraint(sprite.body, [ plusX, plusY ], body, [ 0, 0 ]);
            tearWirePlus = wire;
            tearBodyPlus = body;
            wire.attachableEnds.remove(body);
            equilibriumPlus = false;
            break;
          }
          num mA = angle(0, 0, minusX, minusY) + sprite.body.angle / 180 * PI;
          num mD = distance(0, 0, minusX, minusY);
          num mX = sprite.body.x + cos(mA) * mD;
          num mY = sprite.body.y + sin(mA) * mD;
          if (tearConstraintMinus == null && disconnectMinusTimer == 0 && distance(mX, mY, body.x, body.y) < 30) {
            tearConstraintMinus = game.physics.p2.createRevoluteConstraint(sprite.body, [ minusX, minusY ], body, [ 0, 0 ]);
            tearWireMinus = wire;
            tearBodyMinus = body;
            wire.attachableEnds.remove(body);
            equilibriumMinus = false;
            break;
          }
        }
      }
    }
    disconnectPlusTimer -= game.time.elapsed / 1000;
    if (disconnectPlusTimer < 0) {
      disconnectPlusTimer = 0;
    }
    disconnectMinusTimer -= game.time.elapsed / 1000;
    if (disconnectMinusTimer < 0) {
      disconnectMinusTimer = 0;
    }
    if (tearConstraintPlus != null) {
      if (tearConstraintPlus.equations[0].multiplier.abs() > TEAR_THRESHOLD) {
        if (equilibriumPlus) {
          game.physics.p2.removeConstraint(tearConstraintPlus);
          tearConstraintPlus = null;
          tearWirePlus.attachableEnds.add(tearBodyPlus);
          disconnectPlusTimer = 0.5;
        }
      } else if (!equilibriumPlus && tearConstraintPlus.equations[0].multiplier != 0) {
        equilibriumPlus = true;
      }
    }
    if (tearConstraintMinus != null) {
      if (tearConstraintMinus.equations[0].multiplier.abs() > TEAR_THRESHOLD) {
        if (equilibriumMinus) {
          game.physics.p2.removeConstraint(tearConstraintMinus);
          tearConstraintMinus = null;
          tearWireMinus.attachableEnds.add(tearBodyMinus);
          disconnectMinusTimer = 0.5;
        }
      } else if (!equilibriumMinus && tearConstraintMinus.equations[0].multiplier != 0) {
        equilibriumMinus = true;
      }
    }
  }

}