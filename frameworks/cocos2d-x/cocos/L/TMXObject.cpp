/**
 *	@file	TMXObject.cpp
 *	@date	2018/02/03
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	TMX∂‘œÛ
 */

#include "TMXObject.h"

L::TMXObject::TMXObject():
	_id(0),
	_x(0),
	_y(0),
	_width(0),
	_height(0),
	_visible(true)
{}

L::TMXObject::~TMXObject() {
	CCLOGINFO("deallocing TMXObject: %p", this);
}

void L::TMXObject::parseObject(xml_node<> *node) {
	CCASSERT(node && !strcmp(node->name(), "object"), "TMXObject: invalid node");

	{
		xml_attribute<> *attr = nullptr;
		attr = node->first_attribute("id");
		if (attr) {
			_id = std::atoi(attr->value());
		}
		attr = node->first_attribute("name");
		if (attr) {
			_name = attr->value();
		}
		attr = node->first_attribute("type");
		if (attr) {
			_type = attr->value();
		}
		attr = node->first_attribute("x");
		if (attr) {
			_x = std::atoi(attr->value());
		}
		attr = node->first_attribute("y");
		if (attr) {
			_y = std::atoi(attr->value());
		}
		attr = node->first_attribute("width");
		if (attr) {
			_width = std::atoi(attr->value());
		}
		attr = node->first_attribute("height");
		if (attr) {
			_height = std::atoi(attr->value());
		}
		attr = node->first_attribute("visible");
		if (attr) {
			_visible = std::atoi(attr->value()) != 0;
		}
	}

	xml_node<> *propsnode = node->first_node("properties");
	if (propsnode){
		for (xml_node<> *prop = propsnode->first_node("property"); prop;
			prop = prop->next_sibling("property")) {
			_properties.emplace(prop->first_attribute("name")->value(),
				prop->first_attribute("value")->value());
		}
	}
}
