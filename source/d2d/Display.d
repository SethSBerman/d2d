module d2d.Display;

import std.algorithm;
import std.conv;
import std.datetime.stopwatch;
import core.thread;
import d2d;
import d2d.sdl2;

/**
 * A display that handles collecting events and drawing to the screen and handling window stuff
 * Will handle the main loop and send events to where they need to be handled
 */
class Display {

    int framerate = 60; ///The framerate of the window. Will be ignored if the renderer is VSync
    bool isRunning; ///Whether the display is running; will stop running if set to false
    Screen screen; ///The screen that the display is displaying right now
    EventHandler[] eventHandlers; ///All event handlers of the display; define specific behaviours for events; events pass to handlers from first to last
    private ulong _frames; ///How many frames have passed
    private Keyboard _keyboard; ///The keyboard input source
    private Mouse _mouse; ///The mouse input source
    private Window _window; ///The actual SDL window
    private Renderer _renderer; ///The renderer for the window

    /**
     * Gets how many frames have passed since the window started
     */
    @property ulong frames() {
        return this._frames;
    }

    /**
     * Gets the keyboard of the display
     */
    @property Keyboard keyboard() {
        return this._keyboard;
    }

    /**
     * Gets the mouse of the display
     */
    @property Mouse mouse() {
        return this._mouse;
    }

    /**
     * Gets the window of the display
     */
    @property Window window() {
        return this._window;
    }

    /**
     * Gets the contained window's renderer
     */
    @property Renderer renderer() {
        return this._renderer;
    }

    /**
     * Constructs a display given a width, height, window flags, renderer flags, a title, and a path for an image icon (or null)
     * Disregarding width and height, constructor asks for flags first because once set, those cannot be changed
     */
    this(int w, int h, SDL_WindowFlags flags = SDL_WINDOW_SHOWN,
            uint rendererFlags = 0, string title = "", string iconPath = null) {
        this._window = new Window(w, h, flags, title);
        this._renderer = new Renderer(this._window, rendererFlags);
        if (iconPath !is null && iconPath != "") {
            this.window.icon = loadImage(iconPath);
        }
        this._keyboard = new Keyboard();
        this._mouse = new Mouse();
    }

    /**
     * Actually runs the display and handles event collection and framerate and most other things
     */
    void run() {
        this.isRunning = true;
        StopWatch timer = StopWatch(AutoStart.yes);
        while (this.isRunning) {
            timer.reset();
            SDL_Event event;
            while (SDL_PollEvent(&event) != 0) {
                if (event.type == SDL_QUIT) {
                    this.isRunning = false;
                }
                this.mouse.handleEvent(event);
                this.keyboard.handleEvent(event);
                this.eventHandlers.each!(handler => handler.handleEvent(event));
                if (this.screen !is null) {
                    this.screen.components.each!(component => component.handleEvent(event));
                    this.screen.handleEvent(event);
                }
            }
            if (this.screen !is null) {
                this.screen.draw();
                SDL_Rect* oldClipRect = this.renderer.clipRect().handle;
                foreach (component; this.screen.components) {
                    this.renderer.clipRect = component.location;
                    component.draw();
                }
                this.renderer.clipRect = (oldClipRect is null)? null : new iRectangle((*oldClipRect).x, (*oldClipRect).y, (*oldClipRect).w, (*oldClipRect).h);
                this.screen.onFrame();
            }
            this.renderer.present();
            this._frames++;
            if (this.renderer.info.flags & SDL_RENDERER_PRESENTVSYNC) {
                continue;
            }
            immutable sleepTime = 1000 / this.framerate - timer.peek().total!"msecs";
            if (sleepTime > 0) {
                Thread.sleep(msecs(sleepTime));
            }
        }
    }

}
