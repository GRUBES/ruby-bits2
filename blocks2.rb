# PROCS
# We can use Procs to store blocks of code in a variable for reuse later
# There are two methods for creating Procs
# 1. Use the Proc constructor and invoke later with call method
my_proc = Proc.new { puts "tweet" }
my_proc.call
# 2. Use the lambda keyword (these are technically not the same, but
#     they have the same interface)
my_proc = lambda { puts "tweet" }
my_proc.call
# You can also use the alternate "Stabby Lambda" syntax to declare a lambda
my_proc = -> { puts "tweet" }
my_proc.call

# Refactoring example:
# Instead of yielding to a block:
class Tweet
  def post
    if authenticate?(@user, @password)
      yield
    else
      raise 'Auth Error'
    end
  end
end

tweet = Tweet.new('Ruby Bits!')
tweet.post { puts "Sent!" }

# We can explicitly declare a lambda parameter:
class Tweet
  def post(success)
    if authenticate?(@user, @password)
      success.call
    else
      raise 'Auth Error'
    end
  end
end

tweet = Tweet.new('Ruby Bits!')
success = -> { puts "Sent!" }
tweet.post(success)

# We can also do multiple lambdas, like adding one for error handling:
class Tweet
  def post(success, error)
    if authenticate?(@user, @password)
      success.call
    else
      error.call
    end
  end
end

tweet = Tweet.new('Ruby Bits!')
success = -> { puts "Sent!" }
error = -> { raise 'Auth Error' }
tweet.post(success, error)

# Converting between lambdas and blocks
# When calling a method, & turns a Proc parameter into a block
tweets = ["First tweet", "Second tweet"]
printer = lambda { |tweet| puts tweet }
tweets.each(&printer)

# When defining a method, & turns a block parameter into a proc
def each(&block)
end

# Passing blocks through using referencing/de-referencing
# (BAD CODE)
class Timeline
  attr_accessor :tweets

  def each
    tweets.each { |tweet| yield tweet }
  end
end

# Instead we can pass the block through to the each method
# (GOOD CODE)
class Timeline
  attr_accessor :tweets

  def each(&block) # Block to proc
    tweets.each(&block) # proc back to block
  end
end

# & can also convert a symbol into a proc
# This block passes the user of each tweet into the map method
tweets.map { |tweet| tweet.user }

# This can be written simpler as:
tweets.map(&:user)
# The symbol is used as the method name to be called

# This will throw an error because the :user is now a proc, not a user object
tweets.map(&:user.name)

# OPTIONAL BLOCKS
# Ruby has a built in block_given? method that detects whether a block was
# passed in to the method
class Timeline
  attr_accessor :tweets

  def print
    if block_given?
      tweets.each { |tweet| puts yield tweet }
    else
      puts tweets.join(", ")
    end
  end
end

# Can use this mechanism for constructors to initialize objects
class Tweet
  def initialize
    yield self if block_given?
  end
end

Tweet.new do |tweet|
  tweet.status = "Set in initialize"
  tweet.created_at = Time.now
end

# CLOSURES
# Lambdas and procs keep the current state of local variables at the time
# they are created (closures)

# Method returns a new lambda object which accepts a user
def tweet_as(user)
  lambda { |tweet| puts "#{user}: #{tweet}"}
end

# Here we create a closure where the user will be remembered later as greggpollack
gregg_tweet = tweet_as("greggpollack")

# Later, when we put this to use, we only need to specify the message
# because the user is remembered
gregg_tweet.call("Closure tweet!")
