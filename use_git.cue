package dagger_git_sample

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/bash"
	"universe.dagger.io/docker"
)

#Alpine: {
	app: dagger.#FS
	_build: docker.#Build & {
		steps: [
			docker.#Pull & {
				source: "alpine"
			},
			docker.#Copy & {
				contents: app
				source: "./package.json"
				dest: "/app/package.json"
			},
			docker.#Run & {
				command: {
					name: "apk"
					args: ["add", "--update", "nodejs", "npm"]
				}
			},
			docker.#Run & {
				command: {
					name: "npm"
					args: ["install"]
				}
				workdir: "/app"
			}
		]
	}
	image: _build.output
}

dagger.#Plan & {
	client: {
		commands: sops: {
			name: "sops"
			args: ["-d", "./secrets.yml"]
			stdout: dagger.#Secret
		}
		filesystem: {
			"./src": {
				read: contents: dagger.#FS
				write: contents: actions.gitPull.output
			}
			"./app": {
				read: contents: dagger.#FS
			}
		}
	}

	actions: {
		params: {
			git: {
				username: string
				repository: string
				branch: string | *"develop"
			}
			tag: string | *"latest"
			dockerhub: {
				username: string
			}
			image_name: string | *"registry"
		}
		secrets: core.#DecodeSecret & {
			input:  client.commands.sops.stdout
			format: "yaml"
		}

		gitPull: core.#GitPull & {
            remote: params.git.repository
            ref: params.git.branch
			keepGitDir: true
			auth: {
                username: params.git.username
				password: secrets.output.GIT_AUTH_TOKEN_FOR_DAGGER.contents
			}
		}
		list: bash.#RunSimple & {
			script: contents: """
				ls -l /tmp/repository
				"""
			always: true
			mounts: "Local FS": {
				contents: client.filesystem."./src".read.contents
				dest: "/tmp/repository"
			}
		}

		_local_dest: "localhost:5000/\(params.image_name):\(params.tag)"
        _build: #Alpine & {
            app: client.filesystem."./app".read.contents
        }

        // Docker build and npm start. Show responses
        // Before do this action at least once
        // $ cd app && npm install
        getSitemap: docker.#Run & {
        	input: _build.image
        	mounts: "app": {
        		contents: client.filesystem."./app".read.contents
        		dest: "/app"
        	}
        	workdir: "/app"
        	command: {
        		name: "npm"
        		args: ["start"]
        	}
        }

        // Local push
        // Before do this action at least once
        // $ docker run -d -p 5000:5000 registry
        pushLocal: docker.#Push & {
            image: _build.image
            dest: _local_dest
        }
	}
}
