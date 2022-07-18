#include <erl_nif.h>
#include <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    NSWindow* window;
    NSString* appName;
    ErlNifPid serverPid;
}

@property ErlNifEnv* env;
@property (strong) NSStatusItem* statusItem;

@end

@implementation AppDelegate : NSObject

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    appName = NSProcessInfo.processInfo.processName;

    NSMenu* appMenu = NSMenu.new;
    [appMenu addItemWithTitle: [@"Quit " stringByAppendingString: appName]
             action: @selector(terminate:)
             keyEquivalent: @"q"];
    NSMenuItem* appMenuItem = NSMenuItem.new;
    appMenuItem.submenu = appMenu;
    NSApp.mainMenu = NSMenu.new;
    [NSApp.mainMenu addItem: appMenuItem];

    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength: NSVariableStatusItemLength];
    self.statusItem.button.title = @"👀";
    NSMenu* statusMenu = NSMenu.new;
    [statusMenu addItemWithTitle: @"Quit"
                action: @selector(terminate:)
                keyEquivalent: @""];
    self.statusItem.menu = statusMenu;

    window = [NSWindow.alloc initWithContentRect: NSMakeRect(0, 0, 200, 200)
                             styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                             backing: NSBackingStoreBuffered
                             defer: NO];
    window.title = appName;
    [window cascadeTopLeftFromPoint: NSMakePoint(20, 20)];
    [window makeKeyAndOrderFront: self];

    NSApp.ActivationPolicy = NSApplicationActivationPolicyRegular;

    ERL_NIF_TERM name = enif_make_atom(self.env, "Elixir.MAX.Server");
    if (!enif_whereis_pid(NULL, name, &serverPid)) {
        fprintf(stderr, "enif_whereis_pid failed\n");
    }
    [self send:enif_make_atom(self.env, "applicationWillFinishLaunching")];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self send:enif_make_atom(self.env, "applicationDidFinishLaunching")];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self send:enif_make_atom(self.env, "applicationWillTerminate")];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)send:(ERL_NIF_TERM)msg {
    if (!enif_send(NULL, &serverPid, NULL, msg)) {
        NSLog(@"enif_send failed");
    }
}

@end

extern int erl_drv_steal_main_thread(
    char* name,
    ErlNifTid* dtid,
    void* (*func)(void*),
    void* arg,
    ErlNifThreadOpts* opts
);

void *MAXMainLoop(void* env) {
    NSApplication* app = NSApplication.sharedApplication;
    AppDelegate* appDelegate = AppDelegate.new;
    appDelegate.env = env;
    NSApp.delegate = appDelegate;
    (void)app.run;
    return NULL;
}

static ERL_NIF_TERM MAXStart(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    ErlNifTid MAXThread;
    int res = erl_drv_steal_main_thread("MAXThread", &MAXThread, MAXMainLoop, env, NULL);
    return enif_make_atom(env, "ok");
}

static ErlNifFunc nif_funcs[] = {
    {"start", 0, MAXStart}
};

ERL_NIF_INIT(Elixir.MAX.Nif, nif_funcs, NULL, NULL, NULL, NULL)
