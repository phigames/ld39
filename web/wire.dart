part of ld39;

class Wire {

  static const num TEAR_THRESHOLD = 500;

  Scene scene;
  p2.RevoluteConstraint constraintStart, constraintEnd, tearConstraint;
  p2.Body tearBodyA, tearBodyB;
  List<p2.Body> attachableEnds;
  bool equilibrium;

  Wire(this.scene, String key, num startX, num startY, bool constrainedStart, int length, num endX, num endY, [bool constrainedEnd = false, int tearPoint]) {
    attachableEnds = new List<p2.Body>();
    phaser.Sprite<p2.Body> lastRect;
    phaser.Sprite<p2.Body> newRect;
    num width = 20;
    num height = 10;
    num a = angle(startX, startY, endX, endY);
    num d = distance(startX, startY, endX, endY) / length;
    num dX = cos(a) * d;
    num dY = sin(a) * d;
    print('$dX, $dY');
    for (int i = 0; i < length; i++) {
      newRect = game.add.sprite(startX + i * dX, startY + i * dY, key);
      game.physics.p2.enable(newRect);
      newRect.body.angle = a / PI * 180;
      newRect.body.setCollisionGroup(scene.wireCollisionGroup);
      if (lastRect == null) {
        if (constrainedStart) {
          p2.Body fixedBody = new p2.Body(game);
          game.physics.p2.addBody(fixedBody);
          constraintStart = game.physics.p2.createRevoluteConstraint(newRect, [ -width / 2 + height / 2, 0 ], fixedBody, [ startX, startY ]);
          if (i == tearPoint) {
            tearConstraint = constraintStart;
            tearBodyA = newRect.body;
            tearBodyB = null;
          }
        } else {
          attachableEnds.add(newRect.body);
        }
      } else {
        p2.RevoluteConstraint constraint = game.physics.p2.createRevoluteConstraint(newRect, [ -width / 2 + height / 2, 0 ], lastRect, [ width / 2 - height / 2, 0 ]);
        if (i == tearPoint) {
          tearConstraint = constraint;
          tearBodyA = newRect.body;
          tearBodyB = lastRect.body;
        }
        newRect.body.collides(scene.mouseCollisionGroup);
      }
      lastRect = newRect;
    }
    if (constrainedEnd) {
      p2.Body fixedBody = new p2.Body(game);
      game.physics.p2.addBody(fixedBody);
      constraintEnd = game.physics.p2.createRevoluteConstraint(lastRect, [ width / 2 - height / 2, 0 ], fixedBody, [ endX, endY ]);
    } else {
      attachableEnds.add(newRect.body);
      newRect.body.velocity.y = 100;
      newRect.body.velocity.x = 100;
    }
    equilibrium = false;
  }

  void update() {
    if (tearConstraint != null) {
      if (tearConstraint.equations[0].multiplier.abs() > TEAR_THRESHOLD) {
        if (equilibrium) {
          game.physics.p2.removeConstraint(tearConstraint);
          tearConstraint = null;
          if (tearBodyA != null) {
            attachableEnds.add(tearBodyA);
          }
          if (tearBodyB != null) {
            attachableEnds.add(tearBodyB);
          }
        }
      } else if (!equilibrium && tearConstraint.equations[0].multiplier != 0) {
        equilibrium = true;
      }
    }
  }

}