package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/InfluxCommunity/influxdb3-go/influxdb3"
)

func main() {
	if len(os.Args) != 5 {
		fmt.Fprintf(os.Stderr, "Usage: %s <host> <token> <database> <query>\n", os.Args[0])
		os.Exit(1)
	}
	// Instantiate the client.
	client, err := influxdb3.New(influxdb3.ClientConfig{
		Host:     os.Args[1],
		Token:    os.Args[2],
		Database: os.Args[3],
	})
	if err != nil {
		panic(err)
	}

	defer func(client *influxdb3.Client) {
		err := client.Close()
		if err != nil {
			panic(err)
		}
	}(client)

	query := os.Args[4]

	start := time.Now()

	iterator, err := client.Query(context.Background(), query)
	if err != nil {
		panic(err)
	}

	fmt.Fprintln(os.Stdout, "Read all data in the stream:")
	data, err := iterator.Raw().Reader.Read()
	fmt.Fprintln(os.Stdout, data)
	if err != nil {
		panic(err)
	}

	elapsed := time.Since(start).Milliseconds()
	log.Printf("elapsed %d ms", elapsed)
}
