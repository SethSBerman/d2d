module d2d.graphics.Renderer;

import d2d.graphics.Texture;
import d2d.Window;

import derelict.sdl2.sdl;

class Renderer {

    private SDL_Renderer* renderer;

    this(Window window){
        renderer = SDL_CreateRenderer(window.getSDL);
    }

    @property SDL_Renderer* getSDL(){
        return this.renderer;
    }

    void copy(Texture texture, int x, int y){
        SDL_Rect drect = SDL_Rect(x, y, 0, 0);
        SDL_RenderCopy(this.renderer, texture.getSDL, null, &drect);
    }

    void fill(int r, int g, int b, int a=255){
        this.setColor(r, g, b, a);
        SDL_RenderClear(this.renderer);
    }

    void fill(){
        SDL_RenderClear(this.renderer);
    }

    void setColor(int r, int g, int b, int a=255){
        SDL_SetRenderDrawColor(this.renderer, cast(ubyte)r, cast(ubyte)g, cast(ubyte)b, cast(ubyte)a);
    }

}
