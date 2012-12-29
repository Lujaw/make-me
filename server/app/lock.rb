require_relative '../lib/lock'

module PrintMe
  class App
    LOCK_FILE = File.join('tmp', 'printing.lock')
    LOCK = PrintMe::Lock.new LOCK_FILE

    get '/lock' do
      require_basic_auth
      if reason = locked?
        halt 423, reason
      else
        status 200
        "Unlocked"
      end
    end

    post '/unlock' do
      require_basic_auth
      # If process is still running, don't allow an unlock
      if locked? && !File.exist?(PID_FILE)
        LOCK.unlock!
        status 200
        "Lock cleared!"
      else
        status 404
        "No lock found or still printing"
      end
    end

    helpers do
      def locked?
        LOCK.locked?
      end

      def lock!
        LOCK.lock!
      end
    end
  end
end
