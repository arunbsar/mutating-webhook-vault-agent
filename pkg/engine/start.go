package engine

import (
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/openlab-red/mutating-webhook-vault-agent/pkg/kubernetes"
	"github.com/spf13/viper"
)

func Start() {
	var engine = gin.New()

	kubernetes.InitLogrus(engine)

	engine.GET("/health", health)

	hook(engine)

	engine.RunTLS(":"+viper.GetString("port"), "/var/run/secrets/kubernetes.io/certs/tls.crt", "/var/run/secrets/kubernetes.io/certs/tls.key")

	shutdown(engine)
}

func hook(engine *gin.Engine) {

	sidecarConfig := kubernetes.SidecarConfig{}
	kubernetes.Load("/var/run/secrets/kubernetes.io/config/sidecarconfig.yaml", &sidecarConfig)
	fmt.Println("Testing hook")
	wk := kubernetes.WebHook{
		SidecarConfig: &sidecarConfig,
	}

	engine.POST("/mutate", wk.Mutate)

}
