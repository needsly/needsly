## Remote synchronization algorithm

Server and local version are represented as timestamp. Timestamp is equal to the current time without timezone offsets as devices can be in different timezones and thus happened-before relation might be broken.

If server version == local version then do nothing;
If server version > local version then apply server changes;
If server version < local version then merge and apply changes.