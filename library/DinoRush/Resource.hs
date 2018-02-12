module DinoRush.Resource where

import qualified SDL
import qualified SDL.Mixer as Mixer
import qualified SDL.Image as Image
import qualified Animate
import Data.StateVar (($=))
import SDL.Vect

import DinoRush.Config
import DinoRush.Engine.Types
import DinoRush.Engine.Dino
import DinoRush.Engine.Bird
import DinoRush.Engine.Bouncer
import DinoRush.Engine.Lava
import DinoRush.Engine.Mountain
import DinoRush.Engine.Rock

loadSurface :: FilePath -> Maybe Animate.Color -> IO SDL.Surface
loadSurface path alpha = do
  surface <- Image.load path
  case alpha of
    Just (r,g,b) -> SDL.surfaceColorKey surface $= (Just $ V4 r g b 0x00)
    Nothing -> return ()
  return surface

loadResources :: SDL.Renderer -> IO Resources
loadResources renderer = do
  gameMusic <- Mixer.load "resource/v42.mod"
  jumpSfx <- Mixer.load "resource/dino_jump.wav"
  mountainSprites <- Animate.readSpriteSheetJSON loadTexture "resource/mountain.json" :: IO (Animate.SpriteSheet MountainKey SDL.Texture Seconds)
  jungle <- loadTexture "resource/jungle.png" Nothing
  ground <- loadTexture "resource/ground.png" Nothing
  river <- loadTexture "resource/river.png" Nothing
  dinoSprites <- Animate.readSpriteSheetJSON loadTexture "resource/dino.json" :: IO (Animate.SpriteSheet DinoKey SDL.Texture Seconds)
  birdSprites <- Animate.readSpriteSheetJSON loadTexture "resource/bird.json" :: IO (Animate.SpriteSheet BirdKey SDL.Texture Seconds)
  bouncerSprites <- Animate.readSpriteSheetJSON loadTexture "resource/bouncer.json" :: IO (Animate.SpriteSheet BouncerKey SDL.Texture Seconds)
  lavaSprites <- Animate.readSpriteSheetJSON loadTexture "resource/lava.json" :: IO (Animate.SpriteSheet LavaKey SDL.Texture Seconds)
  rockSprites <- Animate.readSpriteSheetJSON loadTexture "resource/rock.json" :: IO (Animate.SpriteSheet RockKey SDL.Texture Seconds)
  return Resources
    { rMountainSprites = mountainSprites
    , rJungleSprites = jungle
    , rGroundSprites = ground
    , rRiverSprites = river
    , rDinoSprites = dinoSprites
    , rBirdSprites = birdSprites
    , rBouncerSprites = bouncerSprites
    , rLavaSprites = lavaSprites
    , rRockSprites = rockSprites
    , rJumpSfx = jumpSfx
    , rGameMusic = gameMusic
    }
  where
    loadTexture path c = SDL.createTextureFromSurface renderer =<< loadSurface path c

freeResources :: Resources -> IO ()
freeResources r = do
  SDL.destroyTexture $ Animate.ssImage (rMountainSprites r)
  SDL.destroyTexture (rJungleSprites r)
  SDL.destroyTexture (rGroundSprites r)
  SDL.destroyTexture (rRiverSprites r)
  SDL.destroyTexture $ Animate.ssImage (rDinoSprites r)
  SDL.destroyTexture $ Animate.ssImage (rBirdSprites r)
  SDL.destroyTexture $ Animate.ssImage (rLavaSprites r)
  SDL.destroyTexture $ Animate.ssImage (rRockSprites r)

  Mixer.free (rGameMusic r)
  Mixer.free (rJumpSfx r)