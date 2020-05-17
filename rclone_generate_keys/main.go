// lol I don't know go so if this sucks please somebody PR it thanks <3
package main

import (
	"github.com/rclone/rclone/fs/config/obscure"
	"fmt"
	"os"
)
func main() {
	if os.Args[1] == "encrypt" {
		fmt.Println(obscure.MustObscure(os.Args[2]))
	} else if os.Args[1] == "decrypt" {
		fmt.Println(obscure.MustReveal(os.Args[2]))
	}
}
