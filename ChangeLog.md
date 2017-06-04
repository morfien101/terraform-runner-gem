0.3.0
    * Removed the action get as a valid action
        - This is not required now since terraform init does this now.
        - This works with remote and local modules
        - The work flow creates a new directory everytime so a init will get the new
          modules each time.
    * Stopped creating new working directories on each run.
        - This is due to the statefile not being left behind as an artifact anymore.
    * Added a change log to keep track of changes.
      