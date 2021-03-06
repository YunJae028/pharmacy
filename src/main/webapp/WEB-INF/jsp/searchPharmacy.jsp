<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
    <header>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="/css/mapstyle.css" rel="stylesheet">
        <title>μ§λ μ°ΎκΈ°</title>
    </header>

    <%@ include file="header.jsp" %>
    <body>
        <div class="map-area">
            <button class="openbtn" onclick="openNav()">π Open List</button>
            <div class="list-area" style="left:0px; position: absolute;">
                <div id="mySidebar" class="sidebar">
                    <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">Γ</a>
                        <div id="list"></div>
                </div>
            </div>
            <select name="searchOption" id="placeOption">
                <option value="place">μμΉ</option>
                <option value="drug">μ½νλͺ</option>
            </select>
            <input id="place" />
            <button id="search">κ²μ</button>
            <button id="currentSearch">νμ¬ μμΉμμ κ²μ</button>
            <div id="map" style="position: relative; width: 1550px;height: 700px;margin-left: 350px;"></div>
        </div>

        <div class="background">
          <div class="window">
            <div class="popup">
              <button id="closePop">Γ</button>
              <div id="drugList">
              </div>
            </div>
            <div>
              <div></div>
            </div>
          </div>
        </div>

    </body>

    <script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=0eec856fe65fd0106ad48250e458cae0&libraries=services"></script>

  <script>
        var mapContainer = document.getElementById('map'), // μ§λλ₯Ό νμν  div
        mapOption = {
            center: new kakao.maps.LatLng(37.686040837930676, 127.04676347327286), // μ§λμ μ€μ¬μ’ν
            level: 1 // μ§λμ νλ λ λ²¨
        };

        var map = new kakao.maps.Map(mapContainer, mapOption); // μ§λλ₯Ό μμ±ν©λλ€

        var bounds = null; // νμ¬ μμΉ
        var markers = [];
        var infoWindows = [];

        // νμ¬ μμΉ μ΄μ©νμ¬ μ½κ΅­ κ²μ
        if (navigator.geolocation) {
            // GeoLocationμ μ΄μ©ν΄μ μ μ μμΉλ₯Ό μ»μ΄μ΅λλ€
            navigator.geolocation.getCurrentPosition(function(position) {

                var lat = position.coords.latitude, // μλ
                    lon = position.coords.longitude; // κ²½λ

                var coords = new kakao.maps.LatLng(lat, lon);

                // μ§λμ μ€μ¬μ κ²°κ³Όκ°μΌλ‘ λ°μ μμΉλ‘ μ΄λμν΅λλ€
                map.setCenter(coords);

                bounds = map.getBounds();
                var center = map.getCenter();

                // μμ­μ λ¨μμͺ½ μ’νλ₯Ό μ»μ΄μ΅λλ€
                var swLatLng = bounds.getSouthWest();
                console.log('λ¨μμͺ½ : ', swLatLng);

                // μμ­μ λΆλμͺ½ μ’νλ₯Ό μ»μ΄μ΅λλ€
                var neLatLng = bounds.getNorthEast();
                console.log('λΆλμͺ½ : ', neLatLng);
                console.log('λΆλμͺ½ Lat : ', neLatLng.getLat());
                console.log('λΆλμͺ½ Lng : ', neLatLng.getLng());

                // μμ­μ λ³΄λ₯Ό λ¬Έμμ΄λ‘ μ»μ΄μ΅λλ€. ((λ¨,μ), (λΆ,λ)) νμμλλ€
                var boundsStr = bounds.toString();
                console.log('μμ­μ λ³΄ λ¬Έμμ΄ : ', boundsStr);

                searchPharmacy();

        });
        } else {
                var params = {
                    currentLat :  37.500501354129156,
                    currentLon : 126.86761643487512
                }

                // νμ¬ μμΉμμ μ½κ΅­ κ²μ
                $.ajax({
                url:"/pharmacyList",
                type:"GET",
                dataType:"json",
                data : params,
                success:function (data){
                    console.log('ajax :', data);
                    //λ§μ»€ νμ
                     searchMarkerInfo(data);
                     $.each(data, function (index, item){
                         $("#list").append("<ul>"+item.dutyName + "</ul>");
                         $("#list").append("<ul>"+item.dutyAddr+"</ul>");
                         $("#list").append("<ul>"+item.dutyTel1+"</ul>");
                     });
                }
            });
        }


    function closeOverlay() {
        for (var i=0;i<infoWindows.length;i++) {
            infoWindows[i].setMap(null);
        }
    }

    function searchMarkerInfo(list){
        $.each(list, function (index, item){
            var checkOpen = item.checkopen;

            if(checkOpen == '0'){
                 imageSrc = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZlcnNpb249IjEuMSIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbG5zOnN2Z2pzPSJodHRwOi8vc3ZnanMuY29tL3N2Z2pzIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgeD0iMCIgeT0iMCIgdmlld0JveD0iMCAwIDUxMiA1MTIiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDUxMiA1MTIiIHhtbDpzcGFjZT0icHJlc2VydmUiIGNsYXNzPSIiPjxnPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgoJPGc+CgkJPHBhdGggZD0iTTI1NiwwQzE1My43NTUsMCw3MC41NzMsODMuMTgyLDcwLjU3MywxODUuNDI2YzAsMTI2Ljg4OCwxNjUuOTM5LDMxMy4xNjcsMTczLjAwNCwzMjEuMDM1ICAgIGM2LjYzNiw3LjM5MSwxOC4yMjIsNy4zNzgsMjQuODQ2LDBjNy4wNjUtNy44NjgsMTczLjAwNC0xOTQuMTQ3LDE3My4wMDQtMzIxLjAzNUM0NDEuNDI1LDgzLjE4MiwzNTguMjQ0LDAsMjU2LDB6IE0yNTYsMjc4LjcxOSAgICBjLTUxLjQ0MiwwLTkzLjI5Mi00MS44NTEtOTMuMjkyLTkzLjI5M1MyMDQuNTU5LDkyLjEzNCwyNTYsOTIuMTM0czkzLjI5MSw0MS44NTEsOTMuMjkxLDkzLjI5M1MzMDcuNDQxLDI3OC43MTksMjU2LDI3OC43MTl6IiBmaWxsPSIjZmYwMDAwIiBkYXRhLW9yaWdpbmFsPSIjMDAwMDAwIiBzdHlsZT0iIiBjbGFzcz0iIj48L3BhdGg+Cgk8L2c+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPC9nPjwvc3ZnPg=="
               var status = 'μ΄μ μ’λ£';
            } else {
                imageSrc = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZlcnNpb249IjEuMSIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbG5zOnN2Z2pzPSJodHRwOi8vc3ZnanMuY29tL3N2Z2pzIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgeD0iMCIgeT0iMCIgdmlld0JveD0iMCAwIDUxMiA1MTIiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDUxMiA1MTIiIHhtbDpzcGFjZT0icHJlc2VydmUiIGNsYXNzPSIiPjxnPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgoJPGc+CgkJPHBhdGggZD0iTTI1NiwwQzE1My43NTUsMCw3MC41NzMsODMuMTgyLDcwLjU3MywxODUuNDI2YzAsMTI2Ljg4OCwxNjUuOTM5LDMxMy4xNjcsMTczLjAwNCwzMjEuMDM1ICAgIGM2LjYzNiw3LjM5MSwxOC4yMjIsNy4zNzgsMjQuODQ2LDBjNy4wNjUtNy44NjgsMTczLjAwNC0xOTQuMTQ3LDE3My4wMDQtMzIxLjAzNUM0NDEuNDI1LDgzLjE4MiwzNTguMjQ0LDAsMjU2LDB6IE0yNTYsMjc4LjcxOSAgICBjLTUxLjQ0MiwwLTkzLjI5Mi00MS44NTEtOTMuMjkyLTkzLjI5M1MyMDQuNTU5LDkyLjEzNCwyNTYsOTIuMTM0czkzLjI5MSw0MS44NTEsOTMuMjkxLDkzLjI5M1MzMDcuNDQxLDI3OC43MTksMjU2LDI3OC43MTl6IiBmaWxsPSIjMDA4NWZiIiBkYXRhLW9yaWdpbmFsPSIjMDAwMDAwIiBzdHlsZT0iIiBjbGFzcz0iIj48L3BhdGg+Cgk8L2c+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPGcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPC9nPgo8ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8L2c+CjxnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjwvZz4KPC9nPjwvc3ZnPg=="
                var status = 'μ΄μ μ€';
            }
            imageSize = new kakao.maps.Size(50, 55);
            imageOption = {offset: new kakao.maps.Point(27, 69)};

            var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption)
            var markerPosition = new kakao.maps.LatLng(item.wgs84Lat,item.wgs84Lon);

            var marker = new kakao.maps.Marker({
                position: markerPosition,
                image : markerImage,
                text : item.dutyName,
            });

            getInfoWindow(marker,item,index);

            marker.setMap(map);


            // μμ±λ λ§μ»€λ₯Ό λ°°μ΄μ μΆκ°ν©λλ€
            markers.push(marker);
        });
    }

    function getInfoWindow(marker,item,index){
        if(item.checkopen == '0'){
        var checkOpen = 'μ΄μμ’λ£ π';
        } else {var checkOpen = 'μ΄μμ€ π';}
        var dutyInventory =  'dutyInventory' + index;
        var content = '<div class="wrap">' +
            '    <div class="info">' +
            '        <div class="title">' +
            '            '+item.dutyName+'' +
            '            <div class="close" onclick="closeOverlay()" title="λ«κΈ°"></div>' +
            '        </div>' +
            '        <div class="body">' +
            '                <div class="ellipsis"> '+ item.dutyAddr+ '</div>' +
            '                <div class="jibun ellipsis">'+ item.dutyTel1+ '</div>' +
            '                <div class="checkOpen">'+ checkOpen + '</div>' +
            '        </div>' +
            '    </div>' +
            '</div>';


        var infoWindow = new kakao.maps.CustomOverlay({
            content: content,
            position: marker.getPosition()
        });
        infoWindows.push(infoWindow);

        // λ§μ»€λ₯Ό ν΄λ¦­νμ λ μ»€μ€ν μ€λ²λ μ΄λ₯Ό νμν©λλ€
        kakao.maps.event.addListener(marker, 'click', function() {
            // All infowindow close
            closeOverlay();

            // infoWindow.open(map,marker);
            infoWindow.setMap(map);
        });
    }

    // λ°°μ΄μ μΆκ°λ λ§μ»€λ€μ μ§λμ νμνκ±°λ μ­μ νλ ν¨μμλλ€
    function setMarkers(map) {
        for (var i = 0; i < markers.length; i++) {
            markers[i].setMap(map);
        }
    }

    $('#search').on('click',function () {

        $("#list").empty();
        setMarkers(null);

        var searchOption = $("#placeOption option:selected").val();

        console.log(searchOption);

        if(searchOption === 'place'){
        // μ£Όμλ₯Ό λ°μμ κ²μ
        // μ£Όμ-μ’ν λ³ν κ°μ²΄λ₯Ό μμ±ν©λλ€
        var geocoder = new kakao.maps.services.Geocoder();

        var address = $('#place').val();

        // μ£Όμ μμΌλ©΄ ν΄λΉ μ£Όμλ‘ κ²μ
        if (address != null && address != '') {
            // μ£Όμλ‘ μ’νλ₯Ό κ²μν©λλ€
            geocoder.addressSearch(address, function (result, status) {
                // μ μμ μΌλ‘ κ²μμ΄ μλ£λμΌλ©΄
                if (status === kakao.maps.services.Status.OK) {
                    var coords = new kakao.maps.LatLng(result[0].y, result[0].x);

                    // μ§λμ μ€μ¬μ κ²°κ³Όκ°μΌλ‘ λ°μ μμΉλ‘ μ΄λμν΅λλ€
                    // map.setCenter(coords);
                    searchPharmacy(coords);
                }
            });
        } else {

        }
        } else if(searchOption === 'drug'){
             searchPharmacy();
        }
    });

     $('#currentSearch').on('click',function () {
        $("#list").empty();
         setMarkers(null);

        searchPharmacy();
     });

     $('#dutyAddr').on('click', function (){


     });

    function searchPharmacy(coords) {

        if (coords != null && coords != '') {
            map.setCenter(coords);
        }

        bounds = map.getBounds();

        // μμ­μ λ¨μμͺ½ μ’νλ₯Ό μ»μ΄μ΅λλ€
        var swLatLng = bounds.getSouthWest();
        console.log('λ¨μμͺ½ : ', swLatLng);

        // μμ­μ λΆλμͺ½ μ’νλ₯Ό μ»μ΄μ΅λλ€
        var neLatLng = bounds.getNorthEast();

        // μμ­μ λ³΄λ₯Ό λ¬Έμμ΄λ‘ μ»μ΄μ΅λλ€. ((λ¨,μ), (λΆ,λ)) νμμλλ€
        var boundsStr = bounds.toString();
        console.log('μμ­μ λ³΄ λ¬Έμμ΄ : ', boundsStr);

        var params = {
            searchOption : $("#placeOption option:selected").val(),
            searchDrugNm : $('#place').val(),
            swLat: swLatLng.getLat(),
            swLng: swLatLng.getLng(),
            neLat: neLatLng.getLat(),
            neLng: neLatLng.getLng()
        }

        // νμ¬ μμΉμμ μ½κ΅­ κ²μ
        $.ajax({
            url: "/pharmacyList",
            type: "GET",
            dataType: "json",
            data: params,
            success: function (data) {
                //λ§μ»€ νμ
                searchMarkerInfo(data);
                $.each(data, function (index, item) {
                    if(data == null || data == ''){
                        $("#list").append("νμ¬ μμΉμ κ²μ κ°λ₯ν μ½κ΅­μ΄ μμ΅λλ€.");
                    } else {
                        if(item.checkopen == '0'){
                        var checkOpen = 'μ΄μμ’λ£ π';
                        } else {var checkOpen = 'μ΄μμ€ π';}
                        var hpid = item.hpid;
                        var dutyName =  'dutyName' + index;
                        var dutyAddr =  'dutyAddr' + index;
                        var dutyTel = 'dutyTel' + index;
                        var checkOpenId =  'checkOpen' + index;
                        var dutyInventory =  'dutyInventory' + index;
                        $("#list").append("<ul id=\"" +  dutyName + "\" class='dutyName'>" + item.dutyName + "</ul>");
                        $("#list").append("<ul id=\"" +  dutyAddr + "\" class='dutyAddr'>" + item.dutyAddr + "</ul>");
                        $("#list").append("<ul id=\"" +  dutyTel + "\" class='dutyTel'>" + item.dutyTel1 + "</ul>");
                        $("#list").append("<ul id=\"" +  checkOpenId + "\" class='checkOpen'>" + checkOpen + "</ul>");
                        $("#list").append("<button id=\"" +  dutyInventory + "\" class='dutyInventory'>"+"μ½νμ¬κ³ "+"</button>");
                        document.getElementById(dutyInventory).addEventListener("click", function() {
                            inventoryPop(hpid);
                        }, false);
                    }
                });
            }
        });
    }

</script>

<script>
function openNav() {
  document.getElementById("mySidebar").style.width = "350px";
  document.getElementById("map").style.marginLeft = "350px";
  // document.getElementById("place").style.marginLeft= "350px";
  // document.getElementById("placeOption").style.marginLeft= "350px";
  // document.getElementById("search").style.marginLeft= "350px";
  // document.getElementById("currentSearch").style.marginLeft= "350px";
}

function closeNav() {
  document.getElementById("mySidebar").style.width = "0";
  document.getElementById("map").style.marginLeft= "0px";
  // document.getElementById("place").style.marginLeft= "0px";
  // document.getElementById("placeOption").style.marginLeft= "0px";
  // document.getElementById("search").style.marginLeft= "0px";
  // document.getElementById("currentSearch").style.marginLeft= "0px";
}

function inventoryPop(srchHpid){
    $("#drugList").empty();
    show();

        var params = {
            hpid : srchHpid
        };

        // μ½ν μ¬κ³  λ¦¬μ€νΈ νμΈ
        $.ajax({
            url: "/drugList",
            type: "GET",
            dataType: "json",
            data: params,
            success: function (data) {
                if(data == null || data == ''){
                     $("#drugList").append("<div style='font-size: 20px;font-weight: bold;color: #ff8080;margin-bottom: 8px;margin-left: 6%;'>μ¬κ³  μ λ³΄κ° μμ΅λλ€</div>");
                } else {
                     $("#drugList").append("<div style='font-size: 20px;font-weight: bold;color: #ff8080;margin-bottom: 8px;margin-left: 6%;'>μ½ν μ¬κ³ </div>");
                    // $("#drugList").append("<input id = 'srchDrug' />");
                    $.each(data, function (index, item) {
                    $("#drugList").append("<ul class = 'dutyName' >"+ ' μ½νλͺ : '+ item.drugName + "</ul>");
                    $("#drugList").append("<ul class = 'dutyAddr'>"+ ' μ μ‘°μ¬ : ' + item.manName + "</ul>");
                    $("#drugList").append("<ul class = 'dragCnt' >"+ ' λ¨μ μλ: ' + item.cnt + "</ul>");
                });
                }
            }
        });
}

  function show() {
    document.querySelector(".background").className = "background show";
  }

  function closePop() {
    document.querySelector(".background").className = "background";
  }

  document.querySelector("#closePop").addEventListener("click", closePop);

// μλμ μΈν λ°μ€ κ°μ λ°λλ€.
var oldVal = $("#srchDrug");

/* κ²μ λ΄μ© λ³κ²½ κ°μ§ */
$("#srchDrug").on("propertychange change keyup paste input", function () {
  // λ³νμ λ°λ‘λ°λ‘ λ°μνλ©΄ λΆνκ° κ±Έλ¦΄ μ μμ΄μ 1μ΄ λλ μ΄λ₯Ό μ€λ€.
  setTimeout(function () {
    // λ³κ²½λ νμ¬ λ°μ€ κ°μ λ°μμ¨λ€.
    var currentVal = $("#srchDrug").val();
    if (currentVal == oldVal) {
      return;
    }
    // ν΄λμ€λ‘ boxλ₯Ό κ°μ§κ³  μλ νκ·Έλ€μ λ°°μ΄ν μν΄
    var listArray = $(".dutyName").toArray();

    // forEachμ μ²«λ²μ§Έ μΈμκ° = λ°°μ΄ λ΄ νμ¬ κ°
    // λλ²μ§Έ κ° = index
    // μΈλ²μ§Έ κ° = νμ¬ λ°°μ΄
    listArray.forEach(function (c, i) {
      var currentList = c;
      // νμ¬ λ°°μ΄κ°μμ λ΄μ© μΆμΆ
      var currentListText = c.innerText;
      // κ²μ λ΄μ©μ ν¬ν¨νμ§ μμ κ²½μ°
      if (currentListText.includes(currentVal) == false) {
        currentList.style.display = "none";
      }
      // κ²μ λ΄μ©μ ν¬ν¨ν  κ²½μ°
      if (currentListText.includes(currentVal)) {
        currentList.style.display = "block";
      }
      // κ²μ λ΄μ©μ΄ μμ κ²½μ°
      if (currentVal.trim() == "") {
        currentList.style.display = "block";
      }
    });
  }, 1000);
});

</script>

</html>