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