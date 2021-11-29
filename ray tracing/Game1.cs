using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using System;

namespace ray_tracing
{
    public class Game1 : Game
    {
        private GraphicsDeviceManager _graphics;
        private SpriteBatch spriteBatch;
        Texture2D texture;
        Effect effect;
        Vector2 scale, rot = Vector2.Zero;
        Point mouceRot = new Point(0, 0);
        Vector3 pos = new Vector3(-2, 0, 3);
        string s = "\nwasdqe - camera move\n";
        SpriteFont font;
        float samples = 30;

        public Game1()
        {
            
            _graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";
            IsMouseVisible = true;
        }

        protected override void Initialize()
        {
            Mouse.SetPosition(0, 0);
            mouceRot.Y = 180;
            base.Initialize();
            scale = new Vector2(GraphicsDevice.Viewport.Width, GraphicsDevice.Viewport.Height);
        }

        protected override void LoadContent()
        {
            spriteBatch = new SpriteBatch(GraphicsDevice);
            texture = Content.Load<Texture2D>("pixel");
            effect = Content.Load<Effect>("Real ray tracing");
            font = Content.Load<SpriteFont>("fps");

            // TODO: use this.Content to load your game content here
        }

        protected override void Update(GameTime gameTime)
        {
            if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed || Keyboard.GetState().IsKeyDown(Keys.Escape))
                Exit();

            if (Keyboard.GetState().IsKeyDown(Keys.Up))
                samples += (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds) * 2;
            else if(Keyboard.GetState().IsKeyDown(Keys.Down))
                samples -= (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds) * 2;

            if (Keyboard.GetState().IsKeyDown(Keys.E))
                pos.Z += (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds);
            else if (Keyboard.GetState().IsKeyDown(Keys.Q))
                pos.Z -= (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds);
            if (Keyboard.GetState().IsKeyDown(Keys.A))
                pos.Y -= (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds);
            else if (Keyboard.GetState().IsKeyDown(Keys.D))
                pos.Y += (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds);
            if (Keyboard.GetState().IsKeyDown(Keys.W))
                pos.X += (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds);
            else if (Keyboard.GetState().IsKeyDown(Keys.S))
                pos.X -= (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds);
            effect.Parameters["_Pos"].SetValue(pos);

            int samp = (int)samples;
            effect.Parameters["_Samples"].SetValue((float)samp);

            /*if (Keyboard.GetState().IsKeyDown(Keys.J))
                lightPos.Y -= (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds) / 2;
            else if (Keyboard.GetState().IsKeyDown(Keys.L))
                lightPos.Y += (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds) / 2;
            if (Keyboard.GetState().IsKeyDown(Keys.I))
                lightPos.X += (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds) / 2;
            else if (Keyboard.GetState().IsKeyDown(Keys.K))
                lightPos.X -= (float)(1f / gameTime.ElapsedGameTime.TotalMilliseconds) / 2;
            lightPos = new Vector3(lightPos.X, lightPos.Y, lightPos.Z);
            //effect.Parameters["_Light"].SetValue(lightPos);*/

            if (Mouse.GetState().X != mouceRot.X)
                rot.X += (Mouse.GetState().X - mouceRot.X) * 0.25f;
            if (Mouse.GetState().Y != mouceRot.Y)
                rot.Y += (Mouse.GetState().X - mouceRot.X) * 0.25f;
            mouceRot = Mouse.GetState().Position;
            effect.Parameters["_MouceRot"].SetValue(new Vector2(mouceRot.X, mouceRot.Y));

            Random rnd = new Random();
            effect.Parameters["_Rand"].SetValue(new Vector3(rnd.Next(1000) - 500, rnd.Next(1000) - 500, rnd.Next(1000) - 500));

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.Black);
            int fps = (int)(1f / (gameTime.ElapsedGameTime.TotalMilliseconds / 1000f));

            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend);
            effect.CurrentTechnique.Passes[0].Apply();
            spriteBatch.Draw(texture, Vector2.Zero, null, Color.White, 0, Vector2.Zero, scale, SpriteEffects.None, 0);
            spriteBatch.End();


            spriteBatch.Begin();
            spriteBatch.DrawString(font, "fps: " + fps + s + (int)samples, new Vector2(5, 0), Color.Black);
            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
