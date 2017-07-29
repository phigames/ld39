part of ld39;

class Switch {

  Scene scene;
  phaser.Sprite<p2.Body> spriteOff, spriteOn; // store body?
  bool switched;

  Switch(this.scene, String key, num x, num y, bool on) {
    spriteOff = game.add.sprite(x, y, key, 0);
    spriteOff.visible = !on;
    game.physics.p2.enable(spriteOff);
    spriteOff.body.kinematic = true;
    spriteOn = game.add.sprite(x, y, key, 1);
    spriteOn.visible = on;
    game.physics.p2.enable(spriteOn);
    spriteOn.body.kinematic = true;
    switched = false;
  }

  void hit() {
    spriteOff.visible = !spriteOff.visible;
    spriteOn.visible = !spriteOn.visible;
    switched = true;
  }

}