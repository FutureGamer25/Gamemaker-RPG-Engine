walkSpeed = 60 * global.dt;
runSpeed = 120 * global.dt;
running = false;
interactDist = 4;

charSprite = char_sprite_create(global.charMapPlayer);

follower_create(obj_follower, id);
follower_create(obj_follower, id);