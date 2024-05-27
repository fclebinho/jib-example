package br.com.clebergomes.jib;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping
public class Hello {

  @GetMapping
  public String sayHello() {
    return "Hello, World!";
  }
}
