package main

import (
	"os"

	"time"

	riak "github.com/basho/riak-go-client"
	"github.com/sirupsen/logrus"
)

func executeShowKey(c *riak.Client, bucket, key string, done chan riak.Command) error {

	cmd, err := riak.NewFetchValueCommandBuilder().
		WithBucketType("safesets").
		WithBucket(bucket).
		WithKey(key).
		Build()
	if err != nil {
		logrus.Info("error building fetchValue ", err, "\n")
		return nil
	}
	async := &riak.Async{
		Command: cmd,
		Done:    done,
	}

	if err = c.ExecuteAsync(async); err != nil {
		logrus.Info("error in queueing showkey command ", err, "\n")
		return err
	}
	return nil
}

func showBucket(c *riak.Client, bucket string) error {

	cb := func(keys []string) error {

		done := make(chan riak.Command, len(keys))

		for _, key := range keys {
			if err := executeShowKey(c, bucket, key, done); err != nil {
				return err
			}
		}

		// read objects
		for i := 0; i < len(keys); i++ {
			select {
			case d := <-done:
				f := d.(*riak.FetchValueCommand)
				obj := f.Response.Values[0]
				logrus.Infof("object: %v, %v, %v\n", obj.Bucket, obj.Key, string(obj.Value))
			case <-time.After(5 * time.Second):
				logrus.Infof("timeout on %s\n", bucket)
			}
		}

		return nil
	}

	logrus.Info("show bucket for ", bucket, "\n")
	cmd, err := riak.NewListKeysCommandBuilder().
		WithAllowListing().
		WithBucketType("safesets").
		WithBucket(bucket).
		WithStreaming(true).
		WithCallback(cb).
		Build()
	if err != nil {
		return err
	}

	if err = c.Execute(cmd); err != nil {
		logrus.Info("error executing showBucket ", err, "\n")
		return err
	}
	/// Can convert cmd to cmd.(*riak.ListKeysCommand), and use its response
	return nil

}

func main() {

	options := riak.NewClientOptions{
		RemoteAddresses: []string{"riak:8087"},
	}
	c, err := riak.NewClient(&options)
	if err != nil {
		logrus.Infof("error = %v\n", err)
		os.Exit(1)
	}

	builder := riak.NewListBucketsCommandBuilder()
	cb := func(buckets []string) error {
		for _, bucket := range buckets {
			if err := showBucket(c, bucket); err != nil {
				return err
			}
		}
		return nil
	}
	cmd, err := builder.WithBucketType("safesets").
		WithAllowListing().
		WithStreaming(true).
		WithCallback(cb).
		Build()
	if err != nil {
		logrus.Info("error building cmd ", err, "\n")
		os.Exit(3)
	}

	err = c.Execute(cmd)
	if err != nil {
		logrus.Info("error executing cmd ", err, "\n")
		os.Exit(2)
	}

	//c.Stop()
}
