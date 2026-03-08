### Design

1. send entire log as message so that better compression may take place as opposed to streaming the output
   1. tee output / stderr
   2. set to logfile and send logfile contents upon exit (success / error)

### Future Work

1. support other pubsub implementations, Amazon SQS
