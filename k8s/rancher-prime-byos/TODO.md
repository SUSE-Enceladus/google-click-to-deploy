List of outstanding tasks to complete:

  * Finish off the schema.yaml
    * deployerServiceAccount definition, if needed
    * serviceAccount.name SERVICE_ACCOUNT definition
    * define bootstrap password property as a GENERATED_PASSWORD
      * see https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/schema.md#type-generated_password

  * Finish off the chart/rancher-prime-byos/templates/application.yaml
    * Finish the post deployment instructions section:
      * Document how to find the rancher endpoint (kubectl ingress or kubectl svc)
      * Document how to connect to run the bootstrap, including how to get generated bootstrap password
    * Finish of the componentKinds section:
      * Should loosely match the kinds of components that will be deployed

  * Implement apptest/tester/tests
    * At a minimum just verify
      * ingress and rancher service are found with kubectl
      * rancher service endpoint is up
  * Revised README.md to reflect Rancher deployment.
