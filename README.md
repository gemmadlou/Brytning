# Brytning

Means mining in Swedish

RabbitMQ installer for Ubuntu Trust 14.04

## Prequisites

* Docker on your host computer/machine

## Get Started

Create a new folder for your project, and then run this command where `mydockercontainer` is the container name.

```
docker run -d -p 5672:5672 --name="mydockercontainer" -v "$(pwd):/var/www" ubuntu:14.04 tail -f /dev/null
```

### Helpful commands

To view queues:

```
sudo rabbitmqctl list_queues
```

To find unacknowledged messages run:

```
sudo rabbitmqctl list_queues name messages_ready messages_unacknowledged
```

### RabbitMQ Notes

#### What if the server crashes?

You'll lose all messages in the queue unless you turn on persistence. Depending on the library you use, it'll be configured differently, however, the configurations should be:

```
Durable = true
```

> You cannot change a non-durable queue to a durable queue. RabbitMQ won't allow this.

> This option needs to be applied to producers and consumers

Messages need to be persistent:

```
Persistent = true
```

#### How do we guarantee persistence?

You'll need to ensure the queue acknowledges that messages have been handled correctly.

```
noAck = false
```

https://www.rabbitmq.com/confirms.html 

#### Types of messaging queues

**Round Robin** distributes messages evenly and fairly. But evenly isn't good if one set of messages gets a heavy load anothers get a light. Then one will always be busier than the other.

**Fair dispatch**

The consumer needs:

```
Prefetch = 1
```

## Examples

### Captching Up With Tasks That Haven't Been Processed

1) First you need to create a new task in a new file. This contains `durable: true` and `persistent: true` to ensure that the messages persist even if the server crashes.

```js
#!/usr/bin/env node

var amqp = require('amqplib/callback_api');

amqp.connect('amqp://localhost', function(err, conn) {
  conn.createChannel(function(err, ch) {
    var q = 'queue2';
    var msg = process.argv.slice(2).join(' ') || "Hello World!";

    ch.assertQueue(q, {durable: true});
    ch.sendToQueue(q, new Buffer(msg), {persistent: true});
    console.log(" [x] Sent '%s'", msg);
    setTimeout(function() { conn.close(); process.exit(0) }, 500);
  });
});
```
2) Invoke some tasks **WITHOUT** having a consumer being ready to receive them.

```
$ src/yourtask.js
```

3) Afterwards, create a consumer to receive tasks. This must also have the `durable: true`.

```js
#!/usr/bin/env node

var amqp = require('amqplib/callback_api');

amqp.connect('amqp://localhost', function(err, conn) {
  conn.createChannel(function(err, ch) {
    var q = 'queue2';

    ch.assertQueue(q, {durable: true});
    ch.prefetch(1);
    ch.consume(q, function(msg) {
        var secs = msg.content.toString().split('.').length - 1;
        
        console.log(" [x] Received %s", msg.content.toString());
        setTimeout(function() {
          console.log(" [x] Done");
          ch.ack(msg)
        }, secs * 1000);
      }, {noAck: false});
  });
});
```

> You will notice noAck, `ch.ack(msg)` and `ch.prefetch(1)` is used. This forces RabbitMQ to assign a free worker if the consumer is taking time to process a command.