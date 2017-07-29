part of ld39;

class Removable {

  Scene scene;
  phaser.Sprite<p2.Body> sprite; // store body?
  num pivotX, pivotY;
  num damage;

  Removable(this.scene, String key, num x, num y, [this.pivotX, this.pivotY]) {
    sprite = game.add.sprite(x, y, key);
    game.physics.p2.enable(sprite);
    damage = 0;
  }

  void remove() {
    sprite.body.setCollisionGroup(scene.mouseCollisionGroup);
    sprite.body.collides(scene.mouseCollisionGroup);
    sprite.body.collides(scene.wireCollisionGroup);
    if (pivotX != null && pivotY != null) {
      p2.Body fixedBody = new p2.Body(game);
      game.physics.p2.addBody(fixedBody);
      game.physics.p2.createRevoluteConstraint(sprite, [ pivotX, pivotY ], fixedBody, [ sprite.x + pivotX, sprite.y + pivotY ]);
    }
    //sprite.body.velocity.y = 50;
  }

  void hit() {
    damage += 500;
    if (damage > 2000) {
      remove();
    }
    print(damage);
  }

  void update() {
    damage -= game.time.elapsed / 1000;
    if (damage < 0) {
      damage = 0;
    }
  }

}