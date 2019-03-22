.PHONY: dev prepls build

VERSION := $(shell git rev-parse HEAD)

dev:
	CONJURE_LOG_PATH=logs/conjure.log \
	CONJURE_PREPL_SERVER_PORT=5885 \
	CONJURE_JOB_COMMAND="clojure -m conjure.main" \
		nvim -c "source plugin/conjure.vim" src/conjure/main.clj

prepls:
	clj -Aprepls \
		-J-Dclojure.server.jvm="{:port 5555 :accept clojure.core.server/io-prepl}" \
		-J-Dclojure.server.node="{:port 5556 :accept cljs.server.node/prepl}" \
		-J-Dclojure.server.browser="{:port 5557 :accept cljs.server.browser/prepl}"

build:
	mkdir -p bin
	clj -J-Dclojure.compiler.direct-linking=true \
		-J-Dclojure.compiler.elide-meta="[:doc :file :line :added]" \
		-A:pack \
		--main mach.pack.alpha.capsule \
		bin/conjure.jar \
		--application-id conjure \
		--application-version "$(VERSION)" \
		--jvm-args " \
			-client -Xmx2g -Xverify:none \
			-XX:+TieredCompilation -XX:TieredStopAtLevel=1 \
			-XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled \
		" \
		--main conjure.main
