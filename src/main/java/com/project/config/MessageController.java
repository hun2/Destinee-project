package com.project.config;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Controller
@ServerEndpoint("/websocket")
public class MessageController {

	
	 private static final List<Session> session = new ArrayList<Session>();

	    public MessageController() {
//	        this.isSessionClosed();
	    }

	    @GetMapping("/test")
	    public String index() {
	        return "/main/index";
	    }

	    @OnOpen
	    public void open(Session newUser) {
	        System.out.println("connected");
	        session.add(newUser);
	        System.out.println("현재 접속중인 유저 수 : " + session.size());
	    }

	    @OnMessage
	    public void getMsg(Session recieveSession, String msg) {
	        for (int i = 0; i < session.size(); i++) {
	            if (! recieveSession.getId().equals(session.get(i).getId())) {
	                try {
	                    session.get(i).getBasicRemote().sendText("유저" + (Integer.parseInt(session.get(i).getId()) + 1) + " : " + msg);
	                } catch (IOException e) {
	                    e.printStackTrace();
	                }
	            } else {
	                try {
	                    session.get(i).getBasicRemote().sendText("나 : " + msg);
	                } catch (IOException e) {
	                    e.printStackTrace();
	                }
	            }
	        }
	    }

	    @Scheduled(cron = "* * * * * *")
	    private void isSessionClosed() {
	        if (session.size() != 0) {
	            try {
	                System.out.println("! = " + session.size());
	                for (int i = 0; i < session.size(); i++) {
	                    if (! session.get(i).isOpen()) {
	                        session.remove(i);
	                    }
	                }
	            } catch (Exception e) {
	                e.printStackTrace();
	            }
	        }
	    }
}