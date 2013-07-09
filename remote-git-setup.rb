require 'colorize'

class String
	def snakify
		self.downcase.gsub(/\s/, '-')
	end
end

def self.arguments_valid?

	if ARGV.count < 2
		puts "Must specify a project name and the working directory i.e. \"My Project\" \"./Sites/my_project\"".red
		false
	else
		true
	end
end

begin

	if arguments_valid?

		project = ARGV[0]
		worktree = ARGV[1]

		repo = "#{project}.git".snakify

		puts ""
		puts "Remote git setup started for '#{project}':".underline
		puts

		# create .git_repos if it doesn't exist
		if not File.directory? '.git_repos'
			puts "Creating .git_repos Directory".green
			Dir.mkdir '.git_repos'
		else
			puts ".git_repos directory exists, will be using it".yellow
		end

		# go into .git_repos and begin the magic
		Dir.chdir '.git_repos'

		puts "Creating git repo: #{repo}".green

		# Make sure we don't overwrite things
		if not File.directory? repo
			Dir.mkdir repo
		else
			puts "WARNING: #{repo} exists already, overwrite (yes) or enter repo name?".red
			decision = $stdin.gets.chomp

			if not decision == 'yes'
				repo = decision
			end
		end

		if not File.directory? repo
			Dir.mkdir repo
		end

		# Initialize bare repo
		Dir.chdir repo
		system 'git init --bare'

		# Add post-receive hook
		puts "Adding post-receive hook".green
		post_receive = File.open './hooks/post-receive', 'w'
		post_receive.write "#!/bin/sh\r\n"

		script_filename = project.snakify

		post_receive.write "sudo /usr/local/bin/#{script_filename}\r\n"
		post_receive.close

		workdir = "#{worktree}#{script_filename}"

		# Create script to run when post-receive is called
		puts "Creating script file #{script_filename} with work dir #{workdir}".green

		script = File.open "/usr/local/bin/#{script_filename}", 'w+'
		script.write "#!/bin/sh\r\n"
		script.write "GIT_WORK_TREE=#{workdir} git checkout -f"

		puts

		puts "There are a couple of small steps yet to perform:".underline

		puts "1- Grant +x permissions to hooks/post-receive and /usr/local/bin/#{script_filename}".yellow
		puts "sudo chmod +x .git_repos/#{repo}/hooks/post-receive && sudo chmod +x /usr/local/bin/#{script_filename}".green
		puts "2- Create the working directory #{workdir}".yellow
		puts "3- Update visudo by commentng out '# Default requiretty' and adding the following: \r\n".yellow

		visudo = <<-visudo
	git     ALL=(root) NOPASSWD: /usr/local/bin/#{script_filename}
	git     ALL=(root) NOPASSWD: /bin/sh
	git     ALL=(root) NOPASSWD: /bin/sh /usr/local/bin/#{script_filename}
		visudo

		puts visudo.green

		puts "4- Finally, in your local git repository add #{Dir.pwd} as a remote".yellow

	end

rescue SignalException => e
	puts
	puts "Exiting...".red
rescue Exception => e
	puts "ERROR: #{e.message}".red
end

# Dir.chdir repo
# puts "Initializing git repo".green