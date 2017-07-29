part of ld39;

class Wire {

  p2.RevoluteConstraint constraintStart, constraintEnd, tearConstraint;
  p2.Body tearBodyA, tearBodyB;
  List<p2.Body> attachableEnds;
  bool equilibrium;

  Wire(Scene scene, String key, num startX, num startY, bool constrainedStart, int length, [int tearPoint, num endX, num endY]) {
    attachableEnds = new List<p2.Body>();
    phaser.Sprite<p2.Body> lastRect;
    phaser.Sprite<p2.Body> newRect;
    num width = 20;
    num height = 5;
    num angle = atan((endY - startY) / (endX - startX));
    num d = distance(startX, startY, endX, endY) / length;
    num dX = cos(angle) * d;
    num dY = sin(angle) * d;
    for (int i = 0; i < length; i++) {
      newRect = game.add.sprite(startX + i * dX, startY + i * dY, key);
      game.physics.p2.enable(newRect);
      newRect.body.angle = angle / PI * 180;
      newRect.body.setCollisionGroup(scene.wireCollisionGroup);
      if (lastRect == null) {
        if (constrainedStart) {
          p2.Body fixBody = new p2.Body(game);
          game.physics.p2.addBody(fixBody);
          constraintStart = game.physics.p2.createRevoluteConstraint(newRect, [ -width / 2 + height / 2, 0 ], fixBody, [ startX, startY ]);
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
    if (endX != null && endY != null) {
      p2.Body fixBody = new p2.Body(game);
      game.physics.p2.addBody(fixBody);
      constraintEnd = game.physics.p2.createRevoluteConstraint(lastRect, [ width / 2 - height / 2, 0 ], fixBody, [ endX, endY ]);
    } else {
      attachableEnds.add(newRect.body);
    }
    equilibrium = false;
  }

  void update() {
    if (tearConstraint != null) {
      if (tearConstraint.equations[0].multiplier.abs() > 500) {
        if (equilibrium) {
          print('detaching');
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