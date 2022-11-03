package dagger_git_sample

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/bash"
)

dagger.#Plan & {
	client: {
		commands: sops: {
			name: "sops"
			args: ["-d", "./secrets.yml"]
			stdout: dagger.#Secret
		}
		filesystem: {
			"./src/git_test": {
				read: contents: dagger.#FS
				write: contents: actions.gitPull.output
			}
		}
	}

	actions: {
		params: {
			git: {
				username: string
				repository: string
				branch: string | "develop"
			}
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
				contents: client.filesystem."./src/git_test".read.contents
				dest: "/tmp/repository"
			}
		}
	}
}
