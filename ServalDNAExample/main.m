//
//  main.m
//  ServalDNAExample
//
//  Created by James Moore on 4/5/14.
//  Copyright (c) 2014 The Serval Project. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPAppDelegate.h"


#include <signal.h>
#include "serval.h"
#include "conf.h"

static void crash_handler(int signal);
char crash_handler_clue[1024] = "no clue";

int main(int argc, char * argv[])
{
	@autoreleasepool {
        
        /* Catch crash signals so that we can log a backtrace before expiring. */
        struct sigaction sig;
        sig.sa_handler = crash_handler;
        sigemptyset(&sig.sa_mask); // Don't block any signals during handler
        sig.sa_flags = SA_NODEFER | SA_RESETHAND; // So the signal handler can kill the process by re-sending the same signal to itself
        sigaction(SIGSEGV, &sig, NULL);
        sigaction(SIGFPE, &sig, NULL);
        sigaction(SIGILL, &sig, NULL);
        sigaction(SIGBUS, &sig, NULL);
        sigaction(SIGABRT, &sig, NULL);
        
        /* Setup i/o signal handlers */
        signal(SIGPIPE,sigPipeHandler);
        signal(SIGIO,sigIoHandler);
        
        srandomdev();
        cf_init();
        int status = parseCommandLine(NULL, argv[0], argc - 1, (const char*const*)&argv[1]);

        return status;

        
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([SPAppDelegate class]));
	}
}


static void crash_handler(int signal)
{
    LOGF(LOG_LEVEL_FATAL, "Caught signal %s", alloca_signal_name(signal));
    LOGF(LOG_LEVEL_FATAL, "The following clue may help: %s", crash_handler_clue);
    dump_stack(LOG_LEVEL_FATAL);
    BACKTRACE;
    // Now die of the same signal, so that our exit status reflects the cause.
    INFOF("Re-sending signal %d to self", signal);
    kill(getpid(), signal);
    // If that didn't work, then die normally.
    INFOF("exit(%d)", -signal);
    exit(-signal);
}

