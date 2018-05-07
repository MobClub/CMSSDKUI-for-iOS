/* 时间戳转换时间 */
function timeTodate(time){
	var date = new Date(time*1);
	Y = date.getFullYear();
	var month = date.getMonth()+1;
	M = month < 10 ? ('0'+ month) : month;
	var day = date.getDate();
	D = day < 10 ? ('0' + day) : day;
	var hour = date.getHours();
	h = hour < 10 ? ('0' + hour) : hour;
    var minutes = date.getMinutes();
	m = minutes < 10 ? ('0' + minutes) : minutes;
	return Y + '-' + M + '-' + D + ' ' + h + ':' + m;
}

// 计算时间差
function timeDiff(time){
	var diffdate = new Date().getTime() - time;
	var days = Math.floor(diffdate/(24*3600*1000));
	var leave1 = diffdate%(24*3600*1000);   
	var hours = Math.floor(leave1/(3600*1000));  

	var leave2 = leave1%(3600*1000);
	var minutes = Math.floor(leave2/(60*1000));
	var leave3 = leave2%(60*1000);
	var seconds = Math.round(leave3/1000);
	return (days && days > 0) ? days + "天前" : (hours && hours > 0) ? hours + "小时前" : (minutes && minutes > 0) ? minutes + "分钟前" : "刚刚";
}

// 点赞事件
function likeNews(e){
	if($(e).hasClass("over") && !$(e).hasClass("active")){
		CMSSDKNative.likeNews(function(){
			$(e).addClass("active");
			$(e).find("[dz-bind]").html(parseInt($(e).find("[dz-bind]").html()) + 1);
		});
	}else{
		return;
	}
}

/* 渲染评论列表 */
function getCommonHtml(page){
	// 加载flag
	var loading = false;
	// 每次加载添加多少条目
	var itemsPerLoad = 10;

	var pagecout = 0;

	/*获取主题帖子回帖列表*/
	var getPosts = function (pagenum){
		pagecout = pagenum + 1;
		var offset = pagenum * itemsPerLoad;
		CMSSDKNative.getComments(offset, itemsPerLoad, function(resp){
			var data = resp.comments ? resp.comments : [];
			if(data.length > 0){
				// 获取数据成功
				var html = "";
				$.each(data,function(index, item){
					if(index < itemsPerLoad){
						html += '<li><div class="header"><span class="headimg"><img src="'+ ((item.avatar && item.avatar != "") ? item.avatar : "./img/default_user.png") +'"></span><span>'+ (typeof item.nickName == "undefined" ? "游客" : item.nickName) +'</span></div><div class="center">'+ item.content + '</div><div class="bottom"><span>'+ timeDiff(item.updateAt) +'</span></div></li>'; 
					}
				});
				$(".common-content ul").append(html);
				if(pagenum == 0 && resp.comments.length <= itemsPerLoad){
					$.detachInfiniteScroll($('.infinite-scroll'));
					$('.infinite-scroll-preloader').css("display", "none");
					$(".dz-loading-over span").text("加载完成！");
					$(".dz-loading-over").css("display","block");
				}
			}else{
				// 获取数据失败
				$.detachInfiniteScroll($('.infinite-scroll'));
				$('.infinite-scroll-preloader').css("display", "none");
				if(pagenum <= 0){
					$(".dz-loading-over span").text("暂无评论");
				}else{
					$(".dz-loading-over span").text("加载完成！");
				}
				$(".dz-loading-over").css("display","block");
				
			}
		});
		
	};
	//预先加载10条
    getPosts(pagecout);

    $(page).on('infinite', function(){
    	if (loading) return;
    	loading = true;
    	// 模拟1s的加载过程
	    setTimeout(function() {
	       	// 重置加载flag
	        loading = false;

	        // 添加新条目
	        getPosts(pagecout);
	        $.refreshScroller();
	    }, 1000);

    });
}

/* 详情内容渲染 */
function getDetailHtml(data){
	var attachments = function(data,s){
		var html = s;
		html = html.replace(/{{item}}/g, data);
		return html;
	}
	var data = data;
	if (data.updateAt) {
		data.updateAt = timeTodate(data.updateAt);
	}
	$.each($("[dz-bind]"), function(index, item){
		var getAttr = $(item).attr("dz-bind").split(".");
		$(item).html(data[getAttr[1]]);
	});

	
	$.each($("[dz-class]"), function(index, item){
		var getAttr = $(item).attr("dz-class");
		var splitdata = /^{'(.*)':(.*)}$/g.exec(getAttr);
		if(data[splitdata[2].split('.')[1]]){
			 $(item).addClass(splitdata[1]);
		}
	});
	$.each($("[dz-repeat]"), function(index, item){
		var getAttr = $(item).attr("dz-repeat").split(".");
		var els = $(item).html();
		var html = "";
		if(data[getAttr[1]] && data[getAttr[1]].length > 0){
			$.each(data[getAttr[1]], function(index, item){
				var changeels = attachments(item,els);
				html += changeels;
			})
		}
		$(item).html(html);
		
	});
}

$(function(){
	$(document).on("pageInit", ".detail-page", function(e, id, page){
		// 页面初始化完成
		CMSSDKNative.getNewsDetails(function(detailData) {
			getDetailHtml(detailData);
			// 页面初始化完成，获取主题帖子列表
			getCommonHtml(page);
			
		});
	});

	$.init();
});