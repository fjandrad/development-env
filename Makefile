default: latest intel nvidia

# =====
# TOOLS
# =====

tools:
	docker build --rm \
	--build-arg from=diegoferigo/devenv:nvidia \
	--tag fjandrad/tools \
	Tools/

# =====
# TOOLS-Plus
# =====

tools-plus:
	docker build --rm \
	--build-arg from=fjandrad/tools \
	--tag fjandrad/tools-plus \
	Tools_plus/

# ===========
# DEVELOPMENT
# ===========

development-latest: development-master
	docker tag diegoferigo/development:master diegoferigo/development:latest

development-master:
	docker build --rm \
		--build-arg from=diegoferigo/tools \
		--tag diegoferigo/development:master \
		Development/

# ======================
# REINFORCEMENT LEARNING
# ======================

rl-latest: rl-master
	docker tag diegoferigo/rl:master diegoferigo/rl:latest

rl-master:
	docker build --rm \
		--build-arg from=diegoferigo/development:master \
		--tag diegoferigo/rl:master \
		RL/

rl-ubuntu:
	docker build --rm \
		--build-arg from=ubuntu:bionic \
		--tag diegoferigo/rl:ubuntu \
		RL/

# ======
# DEPLOY
# ======

push-tools: tools
	docker push diegoferigo/tools

push-tools-plus: tools-plus
	docker push fjandrad/tools-plus

push-development-latest: development-latest
	docker push diegoferigo/development:latest

push-development-master: development-master
	docker push diegoferigo/development:master

push-rl-latest: rl-latest
	docker push diegoferigo/rl:latest

push-rl-master: rl-master
	docker push diegoferigo/rl:master

push-rl-ubuntu: rl-ubuntu
	docker push diegoferigo/rl:ubuntu
