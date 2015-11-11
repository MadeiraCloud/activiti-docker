【解决流程图中文字体为乱码问题】
Export为jar文件，文件名为activiti-image-generator-5.19.0.jar，放到assets\patch\activiti-explorer\WEB-INF\lib下

diff --git a/modules/activiti-image-generator/src/main/java/org/activiti/image/impl/DefaultProcessDiagramCanvas.java b/modules/activiti-image-generator/src/main/java/org/activiti/image/impl/DefaultProcessDiagramCanvas.java
index faa57a3..e390e0f 100644
--- a/modules/activiti-image-generator/src/main/java/org/activiti/image/impl/DefaultProcessDiagramCanvas.java
+++ b/modules/activiti-image-generator/src/main/java/org/activiti/image/impl/DefaultProcessDiagramCanvas.java
@@ -1086,7 +1086,8 @@ public class DefaultProcessDiagramCanvas {
          Font originalFont = g.getFont();
          Stroke originalStroke = g.getStroke();

-         g.setFont(ANNOTATION_FONT);
+         //disabled by xjimmy, fix chinese font issue
+         //g.setFont(ANNOTATION_FONT);

          Path2D path = new Path2D.Double();
          x += .5;




【activiti-rest支持跨域访问1】

diff --git a/modules/activiti-webapp-rest2/pom.xml b/modules/activiti-webapp-rest2/pom.xml
index d6984b1..bfa9e98 100644
--- a/modules/activiti-webapp-rest2/pom.xml
+++ b/modules/activiti-webapp-rest2/pom.xml
@@ -138,5 +138,16 @@
       <version>3.1.0</version>
       <scope>provided</scope>
     </dependency>
+
+       <dependency>
+               <groupId>com.thetransactioncompany</groupId>
+               <artifactId>cors-filter</artifactId>
+               <version>2.4</version>
+       </dependency>
+       <dependency>
+               <groupId>com.thetransactioncompany</groupId>
+               <artifactId>java-property-utils</artifactId>
+               <version>1.9.1</version>
+       </dependency>
   </dependencies>
 </project>


【activiti-rest支持跨域访问2】
将编译后的modules\activiti-webapp-rest2\target\classes\org\activiti\rest\conf\SecurityConfiguration.class,放到
assets/patch/activiti-rest/WEB-INF/classes/org/activiti/rest/conf/SecurityConfiguration.class

diff --git a/modules/activiti-webapp-rest2/src/main/java/org/activiti/rest/conf/SecurityConfiguration.java b/modules/activiti-webapp-rest2/src/main/java/org/activiti/rest/conf/SecurityConfiguration.java
index c588d8e..cfbcc66 100644
--- a/modules/activiti-webapp-rest2/src/main/java/org/activiti/rest/conf/SecurityConfiguration.java
+++ b/modules/activiti-webapp-rest2/src/main/java/org/activiti/rest/conf/SecurityConfiguration.java
@@ -3,6 +3,7 @@ package org.activiti.rest.conf;
 import org.activiti.rest.security.BasicAuthenticationProvider;
 import org.springframework.context.annotation.Bean;
 import org.springframework.context.annotation.Configuration;
+import org.springframework.http.HttpMethod;
 import org.springframework.security.authentication.AuthenticationProvider;
 import org.springframework.security.config.annotation.web.builders.HttpSecurity;
 import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
@@ -27,6 +28,7 @@ public class SecurityConfiguration extends WebSecurityConfigurerAdapter {
      .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and()
      .csrf().disable()
      .authorizeRequests()
+       .antMatchers(HttpMethod.OPTIONS, "/**").permitAll()//allow CORS option calls
        .anyRequest().authenticated()
        .and()
      .httpBasic();


【activiti-rest支持跨域访问3】
放到assets/patch/activiti-rest/WEB-INF/web.xml

diff --git a/modules/activiti-webapp-rest2/src/main/webapp/WEB-INF/web.xml b/modules/activiti-webapp-rest2/src/main/webapp/WEB-INF/web.xml
index ccc25ad..be8e3af 100644
--- a/modules/activiti-webapp-rest2/src/main/webapp/WEB-INF/web.xml
+++ b/modules/activiti-webapp-rest2/src/main/webapp/WEB-INF/web.xml
@@ -4,6 +4,40 @@
          version="3.0"
          metadata-complete="true">

+    <!-- http://tomcat.apache.org/tomcat-7.0-doc/config/filter.html -->
+    <filter>
+        <filter-name>CORS</filter-name>
+        <filter-class>com.thetransactioncompany.cors.CORSFilter</filter-class>
+        <init-param>
+            <param-name>cors.allowOrigin</param-name>
+            <param-value>*</param-value>
+        </init-param>
+        <init-param>
+            <param-name>cors.supportedMethods</param-name>
+            <param-value>GET, POST, HEAD, PUT, DELETE, OPTIONS</param-value>
+        </init-param>
+        <init-param>
+            <param-name>cors.supportedHeaders</param-name>
+            <param-value>Authorization, Accept, Origin, X-Requested-With, Content-Type, Last-Modified</param-value>
+        </init-param>
+        <init-param>
+            <param-name>cors.exposedHeaders</param-name>
+            <param-value>Set-Cookie</param-value>
+        </init-param>
+        <init-param>
+            <param-name>cors.supportsCredentials</param-name>
+            <param-value>true</param-value>
+        </init-param>
+        <init-param>
+            <param-name>cors.maxAge</param-name>
+            <param-value>300</param-value>
+        </init-param>
+    </filter>
+    <filter-mapping>
+        <filter-name>CORS</filter-name>
+        <url-pattern>/*</url-pattern>
+    </filter-mapping>
+
     <!--
      Remove classpath scanning (from servlet 3.0) in order to speed jetty startup :
      metadata-complete="true" above + empty absolute ordering below

