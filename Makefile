build:
	docker build docker -t andrchalov/pgcron:1.0.0

run:
	docker run -it --name pgcron andrchalov/pgcron:1.0.0

push:
	docker push andrchalov/pgcron:1.0.0
