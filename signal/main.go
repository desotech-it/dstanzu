package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	signalChanel := make(chan os.Signal, 1)
	signal.Notify(signalChanel,
		syscall.SIGHUP,
		syscall.SIGINT,
		syscall.SIGTERM,
		syscall.SIGQUIT)

	exit_chan := make(chan int)
	go func() {
		for {
			s := <-signalChanel
			switch s {
			// kill -SIGHUP XXXX [XXXX - PID for your program]
			case syscall.SIGHUP:
				fmt.Println("Signal hang up triggered.")
				exit_chan <- 0
				// kill -SIGINT XXXX or Ctrl+c  [XXXX - PID for your program]
			case syscall.SIGINT:
				fmt.Println("Signal interrupt triggered.")
				exit_chan <- 0
				// kill -SIGTERM XXXX [XXXX - PID for your program]
			case syscall.SIGTERM:
				fmt.Println("Signal terminte triggered.")
				exit_chan <- 0

				// kill -SIGQUIT XXXX [XXXX - PID for your program]
			case syscall.SIGQUIT:
				fmt.Println("Signal quit triggered.")
				exit_chan <- 0

			default:
				fmt.Println("Unknown signal.")
				exit_chan <- 1
			}
		}
	}()
	exitCode := <-exit_chan
	os.Exit(exitCode)
}

/* Output
➜  ~ kill -SIGINT 451740
	 Terminal 2 - Output - "Signal interrupt triggered."
➜  ~ kill -SIGHUP 451740
	 Terminal 2 - Output - "Signal hang up triggered."
➜  ~ kill -SIGTERM 451740
     Terminal 2 - Output - "Signal terminte triggered."
➜  ~  kill -SIGQUIT 451846
	 Terminal 2 - Output - "Signal quit triggered."
*/
