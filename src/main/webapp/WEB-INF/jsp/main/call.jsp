<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- jquery : ajax, bootstrap, datepicker -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"
	integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
	crossorigin="anonymous"></script>

<!-- bootstrap -->
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
	integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm"
	crossorigin="anonymous">
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"
	integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q"
	crossorigin="anonymous"></script>
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"
	integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl"
	crossorigin="anonymous"></script>
<script src="https://unpkg.com/peerjs@1.4.7/dist/peerjs.min.js"></script>
<!-- material icons -->
<link
	href="https://fonts.googleapis.com/css?family=Material+Icons|Material+Icons+Outlined|Material+Icons+Two+Tone|Material+Icons+Round|Material+Icons+Sharp"
	rel="stylesheet">

<!-- css -->
<link href="/static/css/main.css" rel="stylesheet" />
</head>
<body>
	<div class="main-wrap">

		<!-- navigation -->
		<jsp:include page="../include/nav.jsp" />

		<!-- contents -->
		<section class="content-area">
			<div class="container">
				<!-- content -->
				<div class="content">
					<div class="call-area border">
						<div class="call-top">

							<!-- 카메라 표시 마이크 카메라 설정 -->
							<div class="call-check-status">
							    <input type="text" name="localPeerId" id="localPeerId" class="d-none">
							    <input type="text" name="remotePeerId" id="remotePeerId"  class="d-none">
								<video id="localVideo"></video>
								<video id="remoteVideo"></video>
							</div>

							<!-- 매칭 옵션 체크 -->
							<div class="call-search-option">

								<div class="call-gender-option-subject">
									<span>성별 선택</span>
								</div>
								<div class="call-gender-option-content">
									<input type="radio" id="gender1" name="genderSelectRadio"  value="모두"><label for="gender1">모두</label> 
									<input type="radio" id="gender2" name="genderSelectRadio"  value="남자"><label for="gender2">남자</label>
									<input type="radio" id="gender3" name="genderSelectRadio"  value="여자"><label for="gender3">여자</label>
								</div>
								<div class="call-btn-box">
									<button type="button" id="call-btn" class="btn btn-custom" >랜덤영상통화 시작!</button>
								</div>
							</div>
						</div>

						<div class="call-bottom">

							<!-- 매칭 이력 -->

						</div>
					</div>
				</div>
			</div>
		</section>

		<!-- footer -->
		<jsp:include page="../include/footer.jsp" />
		
	</div>
</body>

<script>
let localStream;
var peer = new Peer();
const inputLocalPeerId = document.getElementById("localPeerId");
const inputRemotePeerId = document.getElementById("remotePeerId");

//비디오 설정 
navigator.mediaDevices.getUserMedia({video:true, audio:true})
    .then(stream => {
        localStream = stream;
        const videoElement = document.getElementById("localVideo");
        videoElement.srcObject = stream;
        videoElement.onloadedmetadata = () => videoElement.play();
    });
peer.on("open", id=> {
    inputLocalPeerId.value = id;

});



$(document).ready(function(){
	
	//변수차단 ( 뒤로가기 , 새로고침, 페이지 이동시 대기방테이블 삭제)
	$(window).bind("beforeunload", function (e){
		
		$.ajax({
			type : "DELETE"
			,url : "/wait_out"
			,success : function(result){
				console.log(result);
			}
			,error : function(){
				
			}
			
		})
			
	});
	
	//동적 클릭 이벤트
	$(document).on("click", "#call-btn", function(){

		var btn = $('#call-btn').text();
		let localid = $('#localPeerId').val().trim();
        let preference = $('input[name="genderSelectRadio"]:checked').val(); 
		//성별선택 안하면 끝내기
		if(preference === undefined) {
			alert('성별을 선택해주세요');
			return false;
		}
		if (btn === '랜덤영상통화 시작!') {
			$('#call-btn').text("매칭취소");
			
	        $.ajax({
	        	type : 'post'
				,url : '/wait_insert'
				,data : {localid, preference}
				,success : function(result) {
					if(result.result === null) {
						console.log("대기방 대기중")
						$('#call-btn').text('멈춤');
					} else {
						console.log("매칭");
						// 원하는 조건의 상대방 카메라 id 값
						var remote = result.result.localid;
						console.log(remote);
						var user_receiveid = result.result.user_id;
						console.log(user_receiveid)
						//input 상대방 태그의 값에 넣어줌 
						$('input[name=remotePeerId]').attr('value', remote);
						
						//넣어준 remoteid값 가져옴 
						const remotePeerId = inputRemotePeerId.value;
					    const call = peer.call(remotePeerId, localStream);
					    call.on("stream", stream => {
					       const remoteVideo =  document.getElementById("remoteVideo");
					       remoteVideo.srcObject = stream;
					       remoteVideo.onloadedmetadata = () => remoteVideo.play();
					      
					    });
					    
					    $('#call-btn').text('멈춤');
					    
					   // 매칭되면 recent 테이블 추가, wait테이블 삭제 ajax
					    $.ajax({
							type : "post"
							,url : "/recent_insert"
							,data : {user_receiveid}
							,success : function(result) {
								if(result.result > 0 ) {
									console.log("대기방 삭제 및 recent 테이블 insert 완료")
								} else {
									console.log("삭제오류있음.")
								}
								
							}
						});
					}
				}
	        });
		} else {
			$('#call-btn').text("랜덤영상통화 시작!");
			$.ajax({
				type : "DELETE"
				,url : "/wait_delete"
				,success : function(result) {
					if(result.result > 0 ) {
						console.log("삭제됨")
					} else {
						console.log("삭제오류있음.")
					}
					
				}
			});
			
		} 
		
	}); //동적이벤트 닫기
	
	
	
});



peer.on("call", call => {
    call.answer(localStream);
    call.on("stream", stream => {
        const remoteVideo =  document.getElementById("remoteVideo");
        remoteVideo.srcObject = stream;
        remoteVideo.onloadedmetadata = () => remoteVideo.play();
    });
});
</script>
</html>