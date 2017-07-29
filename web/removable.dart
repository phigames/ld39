part of ld39;

class Removable {

  Scene scene;
  phaser.Sprite<p2.Body> sprite; // store body?
  p2.RevoluteConstraint constraint;
  num damage;

  Removable(this.scene, String key, num x, num y, [this.constraint]) {
    sprite = game.add.sprite(x, y, key);

  }

  void remove() {
    game.physics.p2.enable(sprite);
    sprite.body.setCollisionGroup(scene.mouseCollisionGroup);
    sprite.body.collides(scene.mouseCollisionGroup);
    sprite.body.collides(scene.wireCollisionGroup);
  }

  void update() {
    damage -= game.time.elapsed / 1000;
    if (damage < 0) {
      damage = 0;
    }
  }

}