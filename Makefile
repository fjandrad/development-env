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
# TOOLS-Pal
# =====

tools-pal:
	docker build --rm \
	--build-arg from=fjandrad/devenv:pal \
	--tag fjandrad/tools-pal \
	Tools_pal/

# =====
# REEM-C
# =====

reem-c:
	docker build --rm \
	--build-arg from=fjandrad/tools-pal \
	--tag fjandrad/reem-c \
	REEM_C/

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

push-tools-pal: tools-pal
	docker push fjandrad/tools-pal

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
